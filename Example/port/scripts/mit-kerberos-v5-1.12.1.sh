#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mit-kerberos-v5
version=1.12.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/mitkrb-1.12.1-db2_fix-1.patch
nwget http://web.mit.edu/kerberos/www/dist/krb5/1.12/krb5-1.12.1-signed.tar

}
unpack()
{
preparepack "$pkgname" "$version" krb5-1.12.1-signed.tar
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
gpg --verify krb5-1.12.1.tar.gz.asc krb5-1.12.1.tar.gz

gpg --keyserver pgp.mit.edu --recv-keys 0xF376813D

patch -Np1 -i ../mitkrb-1.12.1-db2_fix-1.patch 
cd src 
sed -e "s@python2.5/Python.h@& python2.7/Python.h@g" -e "s@-lpython2.5]@&,\n  AC_CHECK_LIB(python2.7,main,[PYTHON_LIB=-lpython2.7])@g" -i configure.in 
sed -e "s@interp->result@Tcl_GetStringResult(interp)@g" -i kadmin/testing/util/tcl_kadm5.c 
sed -e 's@\^u}@^u cols 300}@' -i tests/dejagnu/config/default.exp 
autoconf 
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-system-et --with-system-ss --enable-dns-for-realm 
make

make install 

for LIBRARY in gssapi_krb5 gssrpc k5crypto kadm5clnt kadm5srv kdb5 kdb_ldap krad krb5 krb5support verto ; do
    [ -e  /usr/lib/lib$LIBRARY.so ] && chmod -v 755 /usr/lib/lib$LIBRARY.so
done 

mv -v /usr/lib/libkrb5.so.3*        /lib 
mv -v /usr/lib/libk5crypto.so.3*    /lib 
mv -v /usr/lib/libkrb5support.so.0* /lib 

ln -v -sf ../../lib/libkrb5.so.3.3        /usr/lib/libkrb5.so        
ln -v -sf ../../lib/libk5crypto.so.3.1    /usr/lib/libk5crypto.so    
ln -v -sf ../../lib/libkrb5support.so.0.1 /usr/lib/libkrb5support.so 

mv -v /usr/bin/ksu /bin 
chmod -v 755 /bin/ksu   

install -v -dm755 /usr/share/doc/krb5-1.12.1 
cp -vfr ../doc/*  /usr/share/doc/krb5-1.12.1 

unset LIBRARY

cat > /etc/krb5.conf << "EOF"
# Begin /etc/krb5.conf

[libdefaults]
    default_realm = <LFS.ORG>
    encrypt = true

[realms]
    <LFS.ORG> = {
        kdc = <belgarath.lfs.org>
        admin_server = <belgarath.lfs.org>
        dict_file = /usr/share/dict/words
    }

[domain_realm]
    .<lfs.org> = <LFS.ORG>

[logging]
    kdc = SYSLOG[:INFO[:AUTH]]
    admin_server = SYSLOG[INFO[:AUTH]]
    default = SYSLOG[[:SYS]]

# End /etc/krb5.conf
EOF

kdb5_util create -r <LFS.ORG> -s

kadmin.local
kadmin.local: add_policy dict-only
kadmin.local: addprinc -policy dict-only <loginname>

kadmin.local: addprinc -randkey host/<belgarath.lfs.org>

kadmin.local: ktadd host/<belgarath.lfs.org>

/usr/sbin/krb5kdc

kinit <loginname>

klist

ktutil
ktutil: rkt /etc/krb5.keytab
ktutil: l

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-krb5


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

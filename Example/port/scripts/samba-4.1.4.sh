#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=samba
version=4.1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.samba.org/pub/samba/stable/samba-4.1.4.tar.gz
nwget ftp://ftp.samba.org/pub/samba/stable/samba-4.1.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" samba-4.1.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-piddir=/run/samba --with-pammodulesdir=/lib/security --enable-fhs --enable-nss-wrapper               

make

sed -i "/samba3.blackbox.failure.failure/i \^samba3.raw.eas" selftest/knownfail

make install 

mv -v /usr/lib/libnss_win{s,bind}.so*   /lib                       
ln -v -sf ../../lib/libnss_winbind.so.2 /usr/lib/libnss_winbind.so 
ln -v -sf ../../lib/libnss_wins.so.2    /usr/lib/libnss_wins.so    

install -v -m644    examples/smb.conf.default /etc/samba 

mkdir -pv -pv /etc/openldap/schema                        

install -v -m644    examples/LDAP/README /etc/openldap/schema/README.LDAP  
                    
install -v -m644    examples/LDAP/samba* /etc/openldap/schema              
                    
install -v -m755    examples/LDAP/{get*,ol*} /etc/openldap/schema              

install -v -m755 -d /usr/share/doc/samba-4.1.4 

install -v -m644    lib/ntdb/doc/design.pdf /usr/share/doc/samba-4.1.4

ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

groupadd -g 99 nogroup 
useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup -s /bin/false -u 99 nobody

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-samba

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-winbindd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

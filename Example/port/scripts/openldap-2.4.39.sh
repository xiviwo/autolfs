#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openldap
version=2.4.39
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/openldap-2.4.39-symbol_versions-1.patch
nwget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.39.tgz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/openldap-2.4.39-blfs_paths-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" openldap-2.4.39.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../openldap-2.4.39-blfs_paths-1.patch 
patch -Np1 -i ../openldap-2.4.39-symbol_versions-1.patch 
autoconf 
./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-dynamic --disable-debug --disable-slapd 
make depend 
make 
make install

groupadd -g 83 ldap 
useradd -c "OpenLDAP Daemon Owner" -d /var/lib/openldap -u 83 -g ldap -s /bin/false ldap

patch -Np1 -i ../openldap-2.4.39-blfs_paths-1.patch 
patch -Np1 -i ../openldap-2.4.39-symbol_versions-1.patch 
autoconf 
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/lib --disable-static --disable-debug --enable-dynamic --enable-crypt --enable-spasswd --enable-modules --enable-rlookups --enable-backends=mod --enable-overlays=mod --disable-ndb --disable-sql 
make depend 
make

make install 

chmod -v 700 /var/lib/openldap                                         
chown -v -R ldap:ldap /var/lib/openldap                                
chmod -v 640 /etc/openldap/{slapd.{conf,ldif},DB_CONFIG.example}       
chown -v root:ldap /etc/openldap/{slapd.{conf,ldif},DB_CONFIG.example} 
install -v -dm700 -o ldap -g ldap /etc/openldap/slapd.d                

install -v -dm755  /usr/share/doc/openldap-2.4.39 
cp -vfr doc/drafts /usr/share/doc/openldap-2.4.39 
cp -vfr doc/rfc    /usr/share/doc/openldap-2.4.39 
cp -vfr doc/guide  /usr/share/doc/openldap-2.4.39

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-slapd

/etc/rc.d/init.d/slapd start

ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

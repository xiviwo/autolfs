#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=postfix
version=2.11.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.porcupine.org/mirrors/postfix-release/official/postfix-2.11.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" postfix-2.11.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 32 postfix 
groupadd -g 33 postdrop 
useradd -c "Postfix Daemon User" -d /var/spool/postfix -g postfix -s /bin/false -u 32 postfix 
chown -v postfix:postfix /var/mail

sed -i "s/DB_VERSION_MAJOR == 5/DB_VERSION_MAJOR >= 5/" src/util/dict_db.c

sed -i 's/.\x08//g' README_FILES/*

make CCARGS="-DUSE_TLS -I/usr/include/openssl/ -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl" AUXLIBS="-lssl -lcrypto -lsasl2" makefiles 
make

sh postfix-install -non-interactive daemon_directory=/usr/lib/postfix manpage_directory=/usr/share/man html_directory=/usr/share/doc/postfix-2.11.0/html readme_directory=/usr/share/doc/postfix-2.11.0/readme

cat >> /etc/aliases << "EOF"
# Begin /etc/aliases

MAILER-DAEMON:    postmaster
postmaster:       root

root:             <LOGIN>
# End /etc/aliases
EOF

/usr/sbin/postfix upgrade-configuration

/usr/sbin/postfix check 
/usr/sbin/postfix start

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-postfix


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

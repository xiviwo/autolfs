#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=at
version=3.1.14
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.14.orig.tar.gz
nwget ftp://ftp.de.debian.org/debian/pool/main/a/at/at_3.1.14.orig.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" at_3.1.14.orig.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 17 atd                                                  
useradd -d /dev/null -c "atd daemon" -g atd -s /bin/false -u 17 atd 
mkdir -pv -p /var/spool/cron

./configure --docdir=/usr/share/doc/at-3.1.14 --with-daemon_username=atd --with-daemon_groupname=atd SENDMAIL=/usr/sbin/sendmail 
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-atd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

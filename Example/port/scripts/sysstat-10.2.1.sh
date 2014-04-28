#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sysstat
version=10.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://perso.wanadoo.fr/sebastien.godard/sysstat-10.2.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" sysstat-10.2.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sa_lib_dir=/usr/lib/sa sa_dir=/var/log/sa conf_dir=/etc/sysconfig ./configure --prefix=/usr --disable-man-group 
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-sysstat


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

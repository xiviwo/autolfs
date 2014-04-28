#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfce4-power-manager
version=1.2.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/xfce4-power-manager/1.2/xfce4-power-manager-1.2.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfce4-power-manager-1.2.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
make

make docdir=/usr/share/doc/xfce4-power-manager-1.2.0 imagesdir=/usr/share/doc/xfce4-power-manager-1.2.0/images install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

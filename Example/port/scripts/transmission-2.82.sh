#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=transmission
version=2.82
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.transmissionbt.com/files/transmission-2.82.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/transmission-2.82-qt4-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" transmission-2.82.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../transmission-2.82-qt4-1.patch

./configure --prefix=/usr 
make

pushd qt        
  qmake qtr.pro 
  make          
popd

make install

make INSTALL_ROOT=/usr -C qt install 

install -m644 qt/transmission-qt.desktop /usr/share/applications/transmission-qt.desktop 
install -m644 qt/icons/transmission.png  /usr/share/pixmaps/transmission-qt.png


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

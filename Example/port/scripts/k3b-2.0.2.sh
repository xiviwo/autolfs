#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=k3b
version=2.0.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/k3b-2.0.2-ffmpeg2-1.patch
nwget http://downloads.sourceforge.net/k3b/k3b-2.0.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" k3b-2.0.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../k3b-2.0.2-ffmpeg2-1.patch 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc/kde -Wno-dev ..  
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

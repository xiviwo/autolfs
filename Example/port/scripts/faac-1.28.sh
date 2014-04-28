#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=faac
version=1.28
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/faac/faac-1.28.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/faac-1.28-glibc_fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" faac-1.28.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../faac-1.28-glibc_fixes-1.patch 
sed -i -e '/obj-type/d' -e '/Long Term/d' frontend/main.c 
./configure --prefix=/usr --disable-static 
make

./frontend/faac -o Front_Left.mp4 /usr/share/sounds/alsa/Front_Left.wav

faad Front_Left.mp4
aplay Front_Left.wav

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sdl
version=1.2.15
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.libsdl.org/release/SDL-1.2.15.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" SDL-1.2.15.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/_XData32/s:register long:register _Xconst long:' src/video/x11/SDL_x11sym.h 

./configure --prefix=/usr --disable-static 
make

make install 

install -v -m755 -d /usr/share/doc/SDL-1.2.15/html 
install -v -m644    docs/html/*.html /usr/share/doc/SDL-1.2.15/html

cd test 
./configure 
make


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

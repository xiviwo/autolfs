#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=babl
version=0.1.10
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gimp.org/pub/babl/0.1/babl-0.1.10.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" babl-0.1.10.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -m755 -d /usr/share/gtk-doc/html/babl/graphics 
install -v -m644 docs/*.{css,html} /usr/share/gtk-doc/html/babl 
install -v -m644 docs/graphics/*.{html,png,svg} /usr/share/gtk-doc/html/babl/graphics


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

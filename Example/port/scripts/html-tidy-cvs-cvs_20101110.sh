#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=html-tidy-cvs
version=cvs_20101110
export MAKEFLAGS='-j 4'
download()
{
nwget http://anduin.linuxfromscratch.org/sources/BLFS/svn/t/tidy-cvs_20101110.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" tidy-cvs_20101110.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 

install -v -m644 -D htmldoc/tidy.1 /usr/share/man/man1/tidy.1 
install -v -m755 -d /usr/share/doc/tidy-cvs_20101110 
install -v -m644    htmldoc/*.{html,gif,css} /usr/share/doc/tidy-cvs_20101110


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

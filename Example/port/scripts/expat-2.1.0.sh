#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=expat
version=2.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" expat-2.1.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/expat-2.1.0 
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

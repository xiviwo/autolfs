#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=swig
version=2.0.12
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/swig/swig-2.0.12.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" swig-2.0.12.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -m755 -d /usr/share/doc/swig-2.0.12 
cp -v -R Doc/* /usr/share/doc/swig-2.0.12


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=farstream
version=0.2.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://freedesktop.org/software/farstream/releases/farstream/farstream-0.2.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" farstream-0.2.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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

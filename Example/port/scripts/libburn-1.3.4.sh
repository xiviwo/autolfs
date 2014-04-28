#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libburn
version=1.3.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://files.libburnia-project.org/releases/libburn-1.3.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libburn-1.3.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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

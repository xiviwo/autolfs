#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pnmixer
version=0.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget https://github.com/downloads/nicklan/pnmixer/pnmixer-0.5.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" pnmixer-0.5.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./autogen.sh --prefix=/usr 
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

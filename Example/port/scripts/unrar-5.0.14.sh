#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=unrar
version=5.0.14
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.rarlab.com/rar/unrarsrc-5.0.14.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" unrarsrc-5.0.14.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make -f makefile

install -v -m755 unrar /usr/bin


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-lib
version=1.0.27.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://alsa.cybermirror.org/lib/alsa-lib-1.0.27.2.tar.bz2
nwget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.0.27.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-lib-1.0.27.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure 
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-tools
version=1.0.27
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.alsa-project.org/pub/tools/alsa-tools-1.0.27.tar.bz2
nwget http://alsa.cybermirror.org/tools/alsa-tools-1.0.27.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-tools-1.0.27.tar.bz2
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

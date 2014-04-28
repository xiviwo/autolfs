#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-firmware
version=1.0.27
export MAKEFLAGS='-j 4'
download()
{
nwget http://alsa.cybermirror.org/firmware/alsa-firmware-1.0.27.tar.bz2
nwget ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.27.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-firmware-1.0.27.tar.bz2
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-plugins
version=1.0.27
export MAKEFLAGS='-j 4'
download()
{
nwget http://alsa.cybermirror.org/plugins/alsa-plugins-1.0.27.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/alsa-plugins-1.0.27-ffmpeg2-1.patch
nwget ftp://ftp.alsa-project.org/pub/plugins/alsa-plugins-1.0.27.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-plugins-1.0.27.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../alsa-plugins-1.0.27-ffmpeg2-1.patch 
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-oss
version=1.0.25
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.alsa-project.org/pub/oss-lib/alsa-oss-1.0.25.tar.bz2
nwget http://alsa.cybermirror.org/oss-lib/alsa-oss-1.0.25.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-oss-1.0.25.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --disable-static 
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

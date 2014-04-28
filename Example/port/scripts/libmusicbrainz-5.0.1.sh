#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libmusicbrainz
version=5.0.1
export MAKEFLAGS='-j 4'
download()
{
nwget https://github.com/downloads/metabrainz/libmusicbrainz/libmusicbrainz-5.0.1.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libmusicbrainz-5.0.1-build_system-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" libmusicbrainz-5.0.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libmusicbrainz-5.0.1-build_system-1.patch 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr .. 
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=desktop-file-utils
version=0.22
export MAKEFLAGS='-j 4'
download()
{
nwget http://freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.22.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" desktop-file-utils-0.22.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install

update-desktop-database /usr/share/applications


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

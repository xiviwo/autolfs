#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfburn
version=0.4.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/apps/xfburn/0.4/xfburn-0.4.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfburn-0.4.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/<glib.h>/a#include <glib-object.h>' xfburn/xfburn-settings.h 

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

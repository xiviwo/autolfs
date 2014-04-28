#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mdadm
version=3.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.kernel.org/pub/linux/utils/raid/mdadm/mdadm-3.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" mdadm-3.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
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

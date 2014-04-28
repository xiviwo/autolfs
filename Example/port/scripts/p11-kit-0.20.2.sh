#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=p11-kit
version=0.20.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://p11-glue.freedesktop.org/releases/p11-kit-0.20.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" p11-kit-0.20.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
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

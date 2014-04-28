#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=check
version=0.9.12
export MAKEFLAGS='-j 4'
download()
{
nwget http://sourceforge.net/projects/check/files/check/0.9.12/check-0.9.12.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" check-0.9.12.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make docdir=/usr/share/doc/check-0.9.12 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

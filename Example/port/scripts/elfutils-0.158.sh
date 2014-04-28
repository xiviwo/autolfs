#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=elfutils
version=0.158
export MAKEFLAGS='-j 4'
download()
{
nwget https://fedorahosted.org/releases/e/l/elfutils/0.158/elfutils-0.158.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" elfutils-0.158.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --program-prefix="eu-" 
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

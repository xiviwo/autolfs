#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=jfsutils
version=1.1.15
export MAKEFLAGS='-j 4'
download()
{
nwget http://jfs.sourceforge.net/project/pub/jfsutils-1.1.15.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" jfsutils-1.1.15.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed "s@<unistd.h>@&\n#include <sys/types.h>@g" -i fscklog/extract.c 
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libevent
version=2.0.21
export MAKEFLAGS='-j 4'
download()
{
nwget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libevent-2.0.21-stable.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
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

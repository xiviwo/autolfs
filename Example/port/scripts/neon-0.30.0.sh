#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=neon
version=0.30.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.webdav.org/neon/neon-0.30.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" neon-0.30.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-shared --with-ssl --disable-static 
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

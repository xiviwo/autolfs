#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=apr-util
version=1.5.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/apr/apr-util-1.5.3.tar.bz2
nwget ftp://ftp.mirrorservice.org/sites/ftp.apache.org/apr/apr-util-1.5.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" apr-util-1.5.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-apr=/usr --with-gdbm=/usr --with-openssl=/usr --with-crypto 
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

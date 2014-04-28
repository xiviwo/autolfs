#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libtirpc
version=0.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/project/libtirpc/libtirpc/0.2.4/libtirpc-0.2.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libtirpc-0.2.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-static --disable-gssapi  
make

make install 
mv -v /usr/lib/libtirpc.so.* /lib 
ln -sfv ../../lib/libtirpc.so.1.0.10 /usr/lib/libtirpc.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

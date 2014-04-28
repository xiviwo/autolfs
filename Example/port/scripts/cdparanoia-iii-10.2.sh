#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cdparanoia-iii
version=10.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cdparanoia-III-10.2-gcc_fixes-1.patch
nwget http://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-10.2.src.tgz

}
unpack()
{
preparepack "$pkgname" "$version" cdparanoia-III-10.2.src.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../cdparanoia-III-10.2-gcc_fixes-1.patch 
./configure --prefix=/usr --mandir=/usr/share/man 
make -j1

make install 
chmod -v 755 /usr/lib/libcdda_*.so.0.10.2


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

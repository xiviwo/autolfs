#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=kde-runtime
version=4.12.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/kde-runtime-4.12.2.tar.xz
nwget http://download.kde.org/stable/4.12.2/src/kde-runtime-4.12.2.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/kde-runtime-4.12.2-rpc_fix-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" kde-runtime-4.12.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../kde-runtime-4.12.2-rpc_fix-1.patch 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -DSAMBA_INCLUDE_DIR=/usr/include/samba-4.0 -Wno-dev .. 
make

make install 
ln -sfv ../lib/kde4/libexec/kdesu $KDE_PREFIX/bin/kdesu


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libvpx
version=v1.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://anduin.linuxfromscratch.org/sources/other/libvpx-v1.3.0.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libvpx-v1.3.0.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/cp -p/cp/' build/make/Makefile 
chmod -v 644 vpx/*.h 
mkdir -pv ../libvpx-build 
cd ../libvpx-build 
../libvpx-v1.3.0/configure --prefix=/usr --enable-shared --disable-static 
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

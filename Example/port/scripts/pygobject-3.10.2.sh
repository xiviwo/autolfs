#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pygobject
version=3.10.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/pygobject/3.10/pygobject-3.10.2.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/pygobject/3.10/pygobject-3.10.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" pygobject-3.10.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv python2 
pushd python2 
../configure --prefix=/usr --with-python=/usr/bin/python 
make 
popd

mkdir -pv python3 
pushd python3 
../configure --prefix=/usr --with-python=/usr/bin/python3 
make 
popd

make -C python2 install

make -C python3 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

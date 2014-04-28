#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=d-bus-python
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.2.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dbus-python-1.2.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv python2 
pushd python2 
PYTHON=/usr/bin/python ../configure --prefix=/usr --docdir=/usr/share/doc/dbus-python-1.2.0 
make 
popd

mkdir -pv python3 
pushd python3 
PYTHON=/usr/bin/python3 ../configure --prefix=/usr --docdir=/usr/share/doc/dbus-python-1.2.0 
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

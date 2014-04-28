#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lm-sensors
version=3.3.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://dl.lm-sensors.org/lm-sensors/releases/lm_sensors-3.3.5.tar.bz2
nwget ftp://ftp.netroedge.com/pub/lm-sensors/lm_sensors-3.3.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" lm_sensors-3.3.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make PREFIX=/usr BUILD_STATIC_LIB=0 MANDIR=/usr/share/man

make PREFIX=/usr BUILD_STATIC_LIB=0 MANDIR=/usr/share/man install 

install -v -m755 -d /usr/share/doc/lm_sensors-3.3.5 
cp -rv              README INSTALL doc/* /usr/share/doc/lm_sensors-3.3.5

sensors-detect


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

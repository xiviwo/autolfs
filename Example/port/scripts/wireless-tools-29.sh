#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=wireless-tools
version=29
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.29.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" wireless_tools.29.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make PREFIX=/usr INSTALL_MAN=/usr/share/man install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

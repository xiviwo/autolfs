#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pciutils
version=3.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.2.1.tar.xz
nwget ftp://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.2.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" pciutils-3.2.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make PREFIX=/usr SHAREDIR=/usr/share/misc SHARED=yes

make PREFIX=/usr SHAREDIR=/usr/share/misc SHARED=yes install install-lib      

chmod -v 755 /usr/lib/libpci.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

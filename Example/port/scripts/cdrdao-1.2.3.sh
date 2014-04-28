#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cdrdao
version=1.2.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/cdrdao/cdrdao-1.2.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" cdrdao-1.2.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/ioctl/a #include <sys/stat.h>' dao/ScsiIf-linux.cc 

./configure --prefix=/usr --mandir=/usr/share/man 
make

make install 
install -v -m755 -d /usr/share/doc/cdrdao-1.2.3 
install -v -m644 README /usr/share/doc/cdrdao-1.2.3


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

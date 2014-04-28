#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=jasper
version=1.900.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-1.900.1.zip
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/jasper-1.900.1-security_fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" jasper-1.900.1.zip
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../jasper-1.900.1-security_fixes-1.patch 
./configure --prefix=/usr --enable-shared --disable-static --mandir=/usr/share/man 
make

make install

install -v -m755 -d /usr/share/doc/jasper-1.900.1 
install -v -m644 doc/*.pdf /usr/share/doc/jasper-1.900.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

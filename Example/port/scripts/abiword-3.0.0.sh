#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=abiword
version=3.0.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.abisource.com/downloads/abiword/3.0.0/source/abiword-3.0.0.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/svn/abiword-3.0.0-libgcrypt_1_6_0-1.patch
nwget http://www.abisource.com/downloads/abiword/3.0.0/source/abiword-docs-3.0.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" abiword-3.0.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i abiword-3.0.0-libgcrypt_1_6_0-1.patch 
./configure --prefix=/usr                           
make

make install

tar -xf ../abiword-docs-3.0.0.tar.gz 
cd abiword-docs-3.0.0                
./configure --prefix=/usr            
make

make install

ls /usr/share/abiword-2.9/templates

install -v -m750 -d ~/.AbiSuite/templates 
install -v -m640    /usr/share/abiword-2.9/templates/normal.awt-<lang> ~/.AbiSuite/templates/normal.awt


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

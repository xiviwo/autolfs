#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nasm
version=2.11
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.nasm.us/pub/nasm/releasebuilds/2.11/nasm-2.11-xdoc.tar.xz
nwget http://www.nasm.us/pub/nasm/releasebuilds/2.11/nasm-2.11.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" nasm-2.11.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../nasm-2.11-xdoc.tar.xz --strip-components=1

./configure --prefix=/usr 
make

make install

install -m755 -d         /usr/share/doc/nasm-2.11/html  
cp -v doc/html/*.html    /usr/share/doc/nasm-2.11/html  
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/nasm-2.11       
cp -v doc/info/*         /usr/share/info                   
install-info /usr/share/info/nasm.info /usr/share/info/dir


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

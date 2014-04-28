#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dvd-rw-tools
version=7.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://fy.chalmers.se/~appro/linux/DVD+RW/tools/dvd+rw-tools-7.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dvd+rw-tools-7.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/stdlib/a #include <limits.h>' transport.hxx 
sed -i 's#mkisofs"#xorrisofs"#' growisofs.c 
sed -i 's#mkisofs#xorrisofs#;s#MKISOFS#XORRISOFS#' growisofs.1 

make all rpl8 btcflash

make prefix=/usr install 
install -v -m644 -D index.html /usr/share/doc/dvd+rw-tools-7.1/index.html


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

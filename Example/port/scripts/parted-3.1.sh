#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=parted
version=3.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/parted/parted-3.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" parted-3.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make 

make -C doc html                                       
makeinfo --html      -o doc/html       doc/parted.texi 
makeinfo --plaintext -o doc/parted.txt doc/parted.texi

make install 
install -v -m755 -d /usr/share/doc/parted-3.1/html 
install -v -m644    doc/html/* /usr/share/doc/parted-3.1/html 
install -v -m644    doc/{FAT,API,parted.{txt,html}} /usr/share/doc/parted-3.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

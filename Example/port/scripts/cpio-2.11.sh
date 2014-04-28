#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cpio
version=2.11
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2
nwget http://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" cpio-2.11.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e '/gets is a/d' gnu/stdio.in.h 
./configure --prefix=/usr --bindir=/bin --enable-mt --with-rmt=/usr/libexec/rmt 
make 
makeinfo --html            -o doc/html      doc/cpio.texi 
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi 
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

make install 
install -v -m755 -d /usr/share/doc/cpio-2.11/html 
install -v -m644    doc/html/* /usr/share/doc/cpio-2.11/html 
install -v -m644    doc/cpio.{html,txt} /usr/share/doc/cpio-2.11


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

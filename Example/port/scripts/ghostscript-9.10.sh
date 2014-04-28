#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ghostscript
version=9.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.ghostscript.com/public/ghostscript-9.10.tar.bz2
nwget http://downloads.sourceforge.net/gs-fonts/gnu-gs-fonts-other-6.0.tar.gz
nwget http://downloads.sourceforge.net/gs-fonts/ghostscript-fonts-std-8.11.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" ghostscript-9.10.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
rm -rf expat freetype lcms2 jpeg libpng

rm -rf zlib 
./configure --prefix=/usr --disable-compile-inits --enable-dynamic --with-system-libtiff 
make

make so

bin/gs -Ilib -IResource/Init -dBATCH examples/tiger.eps

make install

make soinstall 
install -v -m644 base/*.h /usr/include/ghostscript 
ln -v -s ghostscript /usr/include/ps

ln -sfv ../ghostscript/9.10/doc /usr/share/doc/ghostscript-9.10

tar -xvf ../<font-tarball> -C /usr/share/ghostscript --no-same-owner


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

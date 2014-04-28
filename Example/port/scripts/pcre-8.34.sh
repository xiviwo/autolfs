#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pcre
version=8.34
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.34.tar.bz2
nwget http://downloads.sourceforge.net/pcre/pcre-8.34.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" pcre-8.34.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/pcre-8.34 --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline --disable-static                 
make

make install                     
mv -v /usr/lib/libpcre.so.* /lib 
ln -sfv ../../lib/$(readlink /usr/lib/libpcre.so) /usr/lib/libpcre.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

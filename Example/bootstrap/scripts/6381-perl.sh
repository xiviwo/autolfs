#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=perl
version=5.18.2
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" perl-5.18.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|" -e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = /usr/include|" -e "s|LIB\s*= ./zlib-src|LIB        = /usr/lib|" cpan/Compress-Raw-Zlib/config.in

sh Configure -des -Dprefix=/usr -Dvendorprefix=/usr -Dman1dir=/usr/share/man/man1 -Dman3dir=/usr/share/man/man3 -Dpager="/usr/bin/less -isR" -Duseshrplib

make



make install

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

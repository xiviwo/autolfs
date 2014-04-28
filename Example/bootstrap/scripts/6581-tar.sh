#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tar
version=1.27.1
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" tar-1.27.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../tar-1.27.1-manpage-1.patch

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --bindir=/bin

make



make install
make -C doc install-html docdir=/usr/share/doc/tar-1.27.1

perl tarman > /usr/share/man/man1/tar.1

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

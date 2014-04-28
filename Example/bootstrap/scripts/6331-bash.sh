#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bash
version=4.2
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" bash-4.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../bash-4.2-fixes-12.patch

./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/bash-4.2 --without-bash-malloc --with-installed-readline

make



-c "PATH=$PATH s"

make install

exec /bin/bash --login +h

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=aspell
version=0.60.6.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz
nwget http://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" aspell-0.60.6.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -m755 -d /usr/share/doc/aspell-0.60.6.1/aspell{,-dev}.html 

install -v -m644 manual/aspell.html/* /usr/share/doc/aspell-0.60.6.1/aspell.html 

install -v -m644 manual/aspell-dev.html/* /usr/share/doc/aspell-0.60.6.1/aspell-dev.html

install -v -m 755 scripts/ispell /usr/bin/

install -v -m 755 scripts/spell /usr/bin/



}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

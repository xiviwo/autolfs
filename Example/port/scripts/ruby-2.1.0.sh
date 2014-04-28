#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ruby
version=2.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" ruby-2.1.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/ruby-2.1.0 --enable-shared 
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

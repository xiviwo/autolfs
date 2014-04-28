#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=subversion
version=1.8.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/subversion/subversion-1.8.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" subversion-1.8.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --with-apache-libexecdir 
make

make install 
install -v -m755 -d /usr/share/doc/subversion-1.8.5 
cp      -v -R       doc/* /usr/share/doc/subversion-1.8.5


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

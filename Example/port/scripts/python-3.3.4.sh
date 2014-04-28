#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=python
version=3.3.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://docs.python.org/ftp/python/doc/3.3.4/python-3.3.4-docs-html.tar.bz2
nwget http://www.python.org/ftp/python/3.3.4/Python-3.3.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" Python-3.3.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi 
make

make install 
chmod -v 755 /usr/lib/libpython3.3m.so 
chmod -v 755 /usr/lib/libpython3.so

export PYTHONDOCS=/usr/share/doc/python-3.3.4/html


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

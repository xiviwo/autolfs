#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=python
version=2.7.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://docs.python.org/ftp/python/doc/2.7.6/python-2.7.6-docs-html.tar.bz2
nwget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" Python-2.7.6.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --enable-unicode=ucs4 
make

make install 
chmod -v 755 /usr/lib/libpython2.7.so.1.0

install -v -dm755 /usr/share/doc/python-2.7.6 
tar --strip-components=1 -C /usr/share/doc/python-2.7.6 --no-same-owner -xvf ../python-2.7.6-docs-html.tar.bz2      
find /usr/share/doc/python-2.7.6 -type d -exec chmod 0755 {} \; 
find /usr/share/doc/python-2.7.6 -type f -exec chmod 0644 {} \;

export PYTHONDOCS=/usr/share/doc/python-2.7.6


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

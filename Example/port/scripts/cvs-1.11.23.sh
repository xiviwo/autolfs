#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cvs
version=1.11.23
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2
nwget ftp://ftp.gnu.org/non-gnu/cvs/source/stable/1.11.23/cvs-1.11.23.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cvs-1.11.23-zlib-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" cvs-1.11.23.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../cvs-1.11.23-zlib-1.patch

sed -i -e 's/getline /get_line /' lib/getline.{c,h} 
sed -i -e 's/^@sp$/& 1/'          doc/cvs.texinfo 
touch doc/*.pdf

./configure --prefix=/usr --docdir=/usr/share/doc/cvs-1.11.23 
make

sed -e 's/rsh};/ssh};/' -e 's/g=rw,o=r$/g=r,o=r/' -i src/sanity.sh

make install 
make -C doc install-pdf 
install -v -m644 FAQ README /usr/share/doc/cvs-1.11.23


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nano
version=2.3.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/nano/nano-2.3.2.tar.gz
nwget http://ftp.gnu.org/gnu/nano/nano-2.3.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" nano-2.3.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 
make

make install 
install -v -m644 doc/nanorc.sample /etc 
install -v -m755 -d /usr/share/doc/nano-2.3.2 
install -v -m644 doc/{,man/,texinfo/}*.html /usr/share/doc/nano-2.3.2


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

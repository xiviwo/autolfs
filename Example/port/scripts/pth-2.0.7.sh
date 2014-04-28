#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pth
version=2.0.7
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz
nwget http://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" pth-2.0.7.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's#$(LOBJS): Makefile#$(LOBJS): pth_p.h Makefile#' Makefile.in 
./configure --prefix=/usr --disable-static --mandir=/usr/share/man 
make

make install 
install -v -m755 -d /usr/share/doc/pth-2.0.7 
install -v -m644    README PORTING SUPPORT TESTS /usr/share/doc/pth-2.0.7


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

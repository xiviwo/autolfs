#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libmpeg2
version=0.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libmpeg2-0.5.1.tar.gz
nwget http://libmpeg2.sourceforge.net/files/libmpeg2-0.5.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libmpeg2-0.5.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/static const/static/' libmpeg2/idct_mmx.c 
./configure --prefix=/usr                           
make

make install 
install -v -m755 -d /usr/share/doc/mpeg2dec-0.5.1 
install -v -m644 README doc/libmpeg2.txt /usr/share/doc/mpeg2dec-0.5.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

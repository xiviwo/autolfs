#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=imlib2
version=1.4.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/enlightenment/imlib2-1.4.6.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" imlib2-1.4.6.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/DGifOpen/s:fd:&, NULL:' src/modules/loaders/loader_gif.c 
sed -i 's/@my_libs@//' imlib2-config.in 
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/imlib2-1.4.6 
install -v -m644    doc/{*.gif,index.html} /usr/share/doc/imlib2-1.4.6


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

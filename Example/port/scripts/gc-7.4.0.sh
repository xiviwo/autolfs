#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gc
version=7.4.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/gc-7.4.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" gc-7.4.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's#pkgdata#doc#' doc/doc.am 
autoreconf -fi  
./configure --prefix=/usr --enable-cplusplus --disable-static --docdir=/usr/share/doc/gc-7.4.0 
make

make install 
install -v -m644 doc/gc.man /usr/share/man/man3/gc_malloc.3 
ln -sfv gc_malloc.3 /usr/share/man/man3/gc.3 


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=s-lang
version=2.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://space.mit.edu/pub/davis/slang/v2.2/slang-2.2.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" slang-2.2.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --with-readline=gnu 
make -j1

make install_doc_dir=/usr/share/doc/slang-2.2.4 SLSH_DOC_DIR=/usr/share/doc/slang-2.2.4/slsh install-all 

chmod -v 755 /usr/lib/libslang.so.2.2.4 /usr/lib/slang/v2/modules/*.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

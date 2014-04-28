#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openssl
version=1.0.1f
export MAKEFLAGS='-j 1'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" openssl-1.0.1f.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../openssl-1.0.1f-fix_parallel_build-1.patch 
patch -Np1 -i ../openssl-1.0.1f-fix_pod_syntax-1.patch 

./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic 
make

sed -i 's# libcrypto.a##;s# libssl.a##' Makefile

make MANDIR=/usr/share/man MANSUFFIX=ssl install 
install -dv -m755 /usr/share/doc/openssl-1.0.1f  
cp -vfr doc/*     /usr/share/doc/openssl-1.0.1f

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

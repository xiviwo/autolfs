#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nss
version=3.15.4
export MAKEFLAGS='-j 1'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/nss-3.15.4-standalone-1.patch
nwget ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_15_4_RTM/src/nss-3.15.4.tar.gz
nwget http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_15_4_RTM/src/nss-3.15.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" nss-3.15.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../nss-3.15.4-standalone-1.patch 
cd nss 
make BUILD_OPT=1 NSPR_INCLUDE_DIR=/usr/include/nspr USE_SYSTEM_ZLIB=1 ZLIB_LIBS=-lz $([ $(uname -m) = x86_64 ] && echo USE_64=1) $([ -f /usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1) -j1

cd ../dist                                                       
install -v -m755 Linux*/lib/*.so              /usr/lib           
install -v -m644 Linux*/lib/{*.chk,libcrmf.a} /usr/lib           
install -v -m755 -d                           /usr/include/nss   
cp -v -RL {public,private}/nss/*              /usr/include/nss   
chmod -v 644                                  /usr/include/nss/* 
install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin 
install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

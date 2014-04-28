#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libmad
version=0.15.1b
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz
nwget http://downloads.sourceforge.net/mad/libmad-0.15.1b.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libmad-0.15.1b-fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" libmad-0.15.1b.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libmad-0.15.1b-fixes-1.patch                
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac 
touch NEWS AUTHORS ChangeLog                                 
autoreconf -fi                                               

./configure --prefix=/usr --disable-static 
make

make install

cat > /usr/lib/pkgconfig/mad.pc << "EOF"
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: mad
Description: MPEG audio decoder
Requires:
Version: 0.15.1b
Libs: -L${libdir} -lmad
Cflags: -I${includedir}
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

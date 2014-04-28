#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libatomic-ops
version=7.2e
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.hpl.hp.com/research/linux/atomic_ops/download/libatomic_ops-7.2e.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libatomic_ops-7.2e.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's#AM_CONFIG_HEADER#AC_CONFIG_HEADERS#' configure.ac 
sed -i 's#AC_PROG_RANLIB#AC_LIBTOOL_DLOPEN\nAC_PROG_LIBTOOL#' configure.ac 
sed -i 's#b_L#b_LTL#;s#\.a#.la#g;s#_a_#_la_#' src/Makefile.am 
sed -i 's#\.a#.so#g;s#\.\./src/#../src/.libs/#g' tests/Makefile.am 
sed -i 's#pkgdata#doc#' doc/Makefile.am 
autoreconf -fi 
./configure --prefix=/usr --docdir=/usr/share/doc/libatomic_ops-7.2e --disable-static 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

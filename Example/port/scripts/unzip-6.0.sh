#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=unzip
version=6.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/infozip/unzip60.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" unzip60.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{


case `uname -m` in
  i?86)
    sed -i -e 's/DASM_CRC"/DASM_CRC -DNO_LCHMOD"/' unix/Makefile
    make -f unix/Makefile linux
    ;;
  *)
    sed -i -e 's/CFLAGS="-O -Wall/& -DNO_LCHMOD/' unix/Makefile
    make -f unix/Makefile linux_noasm
    ;;
esac

make prefix=/usr MANDIR=/usr/share/man/man1 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

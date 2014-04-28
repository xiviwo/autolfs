#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gptfdisk
version=0.8.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/project/gptfdisk/gptfdisk/0.8.8/gptfdisk-0.8.8.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gptfdisk-0.8.8-convenience-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" gptfdisk-0.8.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../gptfdisk-0.8.8-convenience-1.patch 
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

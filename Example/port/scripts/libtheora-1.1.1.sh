#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libtheora
version=1.1.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libtheora-1.1.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/png_\(sizeof\)/\1/g' examples/png2theora.c 
./configure --prefix=/usr --disable-static 
make

make install

cd examples/.libs 
for E in *; do
  install -v -m755 $E /usr/bin/theora_${E}
done


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

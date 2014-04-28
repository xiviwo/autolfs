#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=hd2u
version=1.0.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://hany.sk/~hany/_data/hd2u/hd2u-1.0.3.tgz

}
unpack()
{
preparepack "$pkgname" "$version" hd2u-1.0.3.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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

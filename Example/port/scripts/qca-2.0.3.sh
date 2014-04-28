#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qca
version=2.0.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://delta.affinix.com/download/qca/2.0/qca-2.0.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" qca-2.0.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '217s@set@this->set@' src/botantools/botan/botan/secmem.h 
./configure --prefix=$QTDIR --certstore-path=/etc/ssl/ca-bundle.crt --no-separate-debug-info 
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

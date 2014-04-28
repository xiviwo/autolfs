#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gmp
version=5.1.3
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" gmp-5.1.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{


ABI=64 
	./configure --prefix=/usr --enable-cxx

make

 2>&1 | tee 

awk '/tests passed/{total+=$2} ; END{print total}' 

make install

mkdir -pv /usr/share/doc/gmp-5.1.3
cp    -v doc/{isa_abi_headache,configuration} doc/*.html /usr/share/doc/gmp-5.1.3

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

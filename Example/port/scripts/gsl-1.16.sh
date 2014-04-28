#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gsl
version=1.16
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/pub/gnu/gsl/gsl-1.16.tar.gz
nwget ftp://ftp.gnu.org/pub/gnu/gsl/gsl-1.16.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" gsl-1.16.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make                                       
make html

make install                  
mkdir -pv /usr/share/doc/gsl-1.16 
cp doc/gsl-ref.html/* /usr/share/doc/gsl-1.16


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

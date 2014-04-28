#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=io-socket-ssl
version=1.960
export MAKEFLAGS='-j 4'
download()
{
nwget  http://search.cpan.org/CPAN/authors/id/S/SU/SULLR/IO-Socket-SSL-1.960.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" IO-Socket-SSL-1.960.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
perl Makefile.PL && make && make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

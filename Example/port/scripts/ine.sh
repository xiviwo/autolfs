#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ine
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://search.cpan.org/~gbarr/IO/lib/IO/Socket/INET.pm

}
unpack()
{
preparepack "$pkgname" "$version" INET.pm
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

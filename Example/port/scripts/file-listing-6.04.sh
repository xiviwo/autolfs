#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=file-listing
version=6.04
export MAKEFLAGS='-j 4'
download()
{
nwget http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/File-Listing-6.04.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" File-Listing-6.04.tar.gz
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

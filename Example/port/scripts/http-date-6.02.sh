#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=http-date
version=6.02
export MAKEFLAGS='-j 4'
download()
{
nwget  http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/HTTP-Date-6.02.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" HTTP-Date-6.02.tar.gz
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

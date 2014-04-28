#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=html-parser
version=3.71
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.cpan.org/authors/id/G/GA/GAAS/HTML-Parser-3.71.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" HTML-Parser-3.71.tar.gz
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

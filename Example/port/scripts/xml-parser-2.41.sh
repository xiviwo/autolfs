#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xml-parser
version=2.41
export MAKEFLAGS='-j 4'
download()
{
nwget http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/XML-Parser-2.41.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" XML-Parser-2.41.tar.gz
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

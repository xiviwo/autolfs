#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xml-simple
version=2.20
export MAKEFLAGS='-j 4'
download()
{
nwget http://cpan.org/authors/id/G/GR/GRANTM/XML-Simple-2.20.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" XML-Simple-2.20.tar.gz
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

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=uri
version=1.60
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.cpan.org/authors/id/G/GA/GAAS/URI-1.60.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" URI-1.60.tar.gz
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

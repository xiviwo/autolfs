#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libwww-perl
version=6.05
export MAKEFLAGS='-j 4'
download()
{
nwget http://cpan.org/authors/id/G/GA/GAAS/libwww-perl-6.05.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libwww-perl-6.05.tar.gz
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

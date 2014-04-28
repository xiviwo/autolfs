#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=encode-locale
version=1.03
export MAKEFLAGS='-j 4'
download()
{
nwget  http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Encode-Locale-1.03.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" Encode-Locale-1.03.tar.gz
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

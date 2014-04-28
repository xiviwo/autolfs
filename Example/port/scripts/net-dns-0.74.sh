#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=net-dns
version=0.74
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.cpan.org/authors/id/N/NL/NLNETLABS/Net-DNS-0.74.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" Net-DNS-0.74.tar.gz
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

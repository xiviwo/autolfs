#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=traceroute
version=2.0.19
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/traceroute/traceroute-2.0.19.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" traceroute-2.0.19.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make prefix=/usr install 
mv /usr/bin/traceroute /bin


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

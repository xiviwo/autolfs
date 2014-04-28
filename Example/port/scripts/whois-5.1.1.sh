#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=whois
version=5.1.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.debian.org/debian/pool/main/w/whois/whois_5.1.1.tar.xz
nwget http://ftp.debian.org/debian/pool/main/w/whois/whois_5.1.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" whois_5.1.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make prefix=/usr install-whois
make prefix=/usr install-mkpasswd
make prefix=/usr install-pos


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

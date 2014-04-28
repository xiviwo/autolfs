#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mod-dnssd
version=0.6
export MAKEFLAGS='-j 1'
download()
{
nwget http://0pointer.de/lennart/projects/mod_dnssd/mod_dnssd-0.6.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" mod_dnssd-0.6.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/unixd_setup_child/ap_&/' src/mod_dnssd.c 

./configure --prefix=/usr --disable-lynx 
make

make install
sed -i 's| usr| /usr|' /etc/httpd/httpd.conf


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

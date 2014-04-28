#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=compface
version=1.5.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.xemacs.org/pub/xemacs/aux/compface-1.5.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" compface-1.5.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man 
make

make install 
install -m755 -v xbm2xface.pl /usr/bin


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

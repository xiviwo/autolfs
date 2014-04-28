#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gnumeric
version=1.12.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.10.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/gnumeric/1.12/gnumeric-1.12.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gnumeric-1.12.10.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -e "s@zz-application/zz-winassoc-xls;@@" -i gnumeric.desktop.in 
./configure --prefix=/usr 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

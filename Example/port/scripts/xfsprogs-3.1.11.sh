#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfsprogs
version=3.1.11
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-3.1.11.tar.gz
nwget http://anduin.linuxfromscratch.org/sources/BLFS/svn/x/xfsprogs-3.1.11.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" xfsprogs-3.1.11.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make DEBUG=-DNDEBUG INSTALL_USER=root INSTALL_GROUP=root LOCAL_CONFIGURE_OPTIONS="--enable-readline"

make install install-dev 
rm -rfv /lib/libhandle.{a,la,so} 
ln -sfv ../../lib/libhandle.so.1 /usr/lib/libhandle.so 
sed -i "s@libdir='/lib@libdir='/usr/lib@g" /usr/lib/libhandle.la


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

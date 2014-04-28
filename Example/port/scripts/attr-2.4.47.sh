#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=attr
version=2.4.47
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.savannah.gnu.org/releases/attr/attr-2.4.47.src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" attr-2.4.47.src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in 

INSTALL_USER=root INSTALL_GROUP=root ./configure --prefix=/usr --disable-static 
make

make install install-dev install-lib 
chmod -v 755 /usr/lib/libattr.so 
mv -v /usr/lib/libattr.so.* /lib 
ln -sfv ../../lib/libattr.so.1 /usr/lib/libattr.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

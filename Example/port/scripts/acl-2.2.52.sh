#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=acl
version=2.2.52
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.savannah.gnu.org/releases/acl/acl-2.2.52.src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" acl-2.2.52.src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in 

INSTALL_USER=root INSTALL_GROUP=root ./configure --prefix=/usr --libexecdir=/usr/lib --disable-static 
make

make install install-dev install-lib             
chmod -v 755 /usr/lib/libacl.so                  
mv -v /usr/lib/libacl.so.* /lib                  
ln -sfv ../../lib/libacl.so.1 /usr/lib/libacl.so 
install -v -m644 doc/*.txt /usr/share/doc/acl-2.2.52


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

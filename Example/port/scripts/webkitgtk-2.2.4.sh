#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=webkitgtk
version=2.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://webkitgtk.org/releases/webkitgtk-2.2.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" webkitgtk-2.2.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/generate-gtkdoc --rebase/s:^:# :' GNUmakefile.in

./configure --prefix=/usr --enable-introspection 
make

make install                                    
rm -rf /usr/share/gtk-doc/html/webkitgtk-2.0    
mv -vi /usr/share/gtk-doc/html/webkitgtk{,-2.0}


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

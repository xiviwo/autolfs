#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=webkitgtk
version=1.10.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://webkitgtk.org/releases/webkitgtk-1.10.2.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/webkitgtk-1.10.2-fix_librt_linking-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" webkitgtk-1.10.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/generate-gtkdoc --rebase/s:^:# :' GNUmakefile.in

sed -i '/parse-param/ a%lex-param {YYLEX_PARAM}' Source/ThirdParty/ANGLE/src/compiler/glslang.y

patch -Np1 -i ../webkitgtk-1.10.2-fix_librt_linking-1.patch 
./configure --prefix=/usr --with-gtk=2.0 --disable-webkit2 
make

make install                                    
rm -rf /usr/share/gtk-doc/html/webkitgtk-1.0    
mv -vi /usr/share/gtk-doc/html/webkitgtk{,-1.0}


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

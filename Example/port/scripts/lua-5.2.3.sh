#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lua
version=5.2.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/lua-5.2.3-shared_library-1.patch
nwget http://www.lua.org/ftp/lua-5.2.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lua-5.2.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../lua-5.2.3-shared_library-1.patch 
sed -i '/#define LUA_ROOT/s:/usr/local/:/usr/:' src/luaconf.h 
make linux

make INSTALL_TOP=/usr TO_LIB="liblua.so liblua.so.5.2 liblua.so.5.2.3" INSTALL_DATA="cp -d" INSTALL_MAN=/usr/share/man/man1 install 
mkdir -pv -pv /usr/share/doc/lua-5.2.3 
cp -v doc/*.{html,css,gif,png} /usr/share/doc/lua-5.2.3

cat > /usr/lib/pkgconfig/lua.pc << "EOF"
V=5.2
R=5.2.3

prefix=/usr
INSTALL_BIN=${prefix}/bin
INSTALL_INC=${prefix}/include
INSTALL_LIB=${prefix}/lib
INSTALL_MAN=${prefix}/man/man1
INSTALL_LMOD=${prefix}/share/lua/${V}
INSTALL_CMOD=${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: ${R}
Requires: 
Libs: -L${libdir} -llua -lm
Cflags: -I${includedir}
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=tcl
version=8.6.0
echo "Building -------------- tcl-8.6.0--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf tcl8.6.0-src.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i s/500/5000/ generic/regc_nfa.c
cd unix
./configure --prefix=/tools
make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
echo "End of Building -------------- tcl-8.6.0--------------"

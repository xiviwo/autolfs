#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=kbd
version=1.15.5
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf kbd-1.15.5.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
patch -Np1 -i ../kbd-1.15.5-backspace-1.patch
sed -i -e '326 s/if/while/' src/loadkeys.analyze.l
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make install
mkdir -v       /usr/share/doc/kbd-1.15.5
cp -R -v doc/* /usr/share/doc/kbd-1.15.5

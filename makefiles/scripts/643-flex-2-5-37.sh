#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=flex
version=2.5.37
echo "Building -------------- flex-2.5.37--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf flex-2.5.37.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
patch -Np1 -i ../flex-2.5.37-bison-2.6.1-1.patch
./configure --prefix=/usr             \
            --docdir=/usr/share/doc/flex-2.5.37
make
make install
ln -sv libfl.a /usr/lib/libl.a
cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex
exec /usr/bin/flex -l "$@"
# End /usr/bin/lex
EOF
chmod -v 755 /usr/bin/lex
echo "End of Building -------------- flex-2.5.37--------------"

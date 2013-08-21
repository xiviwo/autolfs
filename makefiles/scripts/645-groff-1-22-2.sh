#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=groff
version=1.22.2
echo "Building -------------- groff-1.22.2--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf groff-1.22.2.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
PAGE=	<paper_size> ./configure --prefix=/usr
make
mkdir -p /usr/share/doc/groff-1.22/pdf
make install
ln -sv eqn /usr/bin/geqn
ln -sv tbl /usr/bin/gtbl
echo "End of Building -------------- groff-1.22.2--------------"

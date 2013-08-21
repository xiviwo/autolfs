#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=texinfo
version=5.1
echo "Building -------------- texinfo-5.1--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf texinfo-5.1.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/usr
make
make install
make TEXMF=/usr/share/texmf install-tex
cd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done
echo "End of Building -------------- texinfo-5.1--------------"

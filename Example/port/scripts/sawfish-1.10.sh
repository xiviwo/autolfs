#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sawfish
version=1.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.tuxfamily.org/sawfish/sawfish-1.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" sawfish-1.10.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-pango  
make

make install

cat >> ~/.xinitrc << "EOF"
exec sawfish
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

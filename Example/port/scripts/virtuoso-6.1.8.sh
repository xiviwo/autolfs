#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=virtuoso
version=6.1.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/virtuoso/virtuoso-opensource-6.1.8.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" virtuoso-opensource-6.1.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s|virt_iodbc_dir/include|&/iodbc|" configure  
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-iodbc=/usr --with-readline --without-internal-zlib --program-transform-name="s/isql/isql-v/" --disable-all-vads --disable-static                          
make

make install 
install -v -m755 -d /usr/share/doc/virtuoso-6.1.8 
ln -svf   -v          ../../virtuoso/doc /usr/share/doc/virtuoso-6.1.8

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-virtuoso


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

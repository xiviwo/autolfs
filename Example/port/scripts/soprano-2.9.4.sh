#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=soprano
version=2.9.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/soprano-2.9.4-dbus-1.patch
nwget http://downloads.sourceforge.net/soprano/soprano-2.9.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" soprano-2.9.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../soprano-2.9.4-dbus-1.patch 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. 
make

make install

install -m755 -d /srv/soprano

cat > /etc/sysconfig/soprano <<EOF
# Begin /etc/sysconfig/soprano

SOPRANO_STORAGE="/srv/soprano"
SOPRANO_BACKEND="virtuoso"                       # virtuoso, sesame2, redland
#SOPRANO_OPTIONS="$SOPRANO_OPTIONS --port 4711"  # Default port is 5000

# End /etc/sysconfig/soprano
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-soprano


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

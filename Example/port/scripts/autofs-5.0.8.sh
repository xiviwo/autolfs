#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=autofs
version=5.0.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.8.tar.xz
nwget ftp://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.8.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" autofs-5.0.8.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/ --mandir=/usr/share/man 
make

make install

mv /etc/auto.master /etc/auto.master.bak 
cat > /etc/auto.master << "EOF"
# Begin /etc/auto.master

/media/auto  /etc/auto.misc  --ghost
#/home        /etc/auto.home

# End /etc/auto.master
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-autofs


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

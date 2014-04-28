#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=configuring-for-network-filesystems
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{

cd ${SOURCES} 

}
build()
{
mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-netfs


}
download;unpack;build

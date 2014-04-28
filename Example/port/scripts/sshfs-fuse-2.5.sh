#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sshfs-fuse
version=2.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/fuse/sshfs-fuse-2.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" sshfs-fuse-2.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install

sshfs THINGY:~ ~/MOUNTPATH

fusermount -u ~/MOUNTPATH


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=alsa-utils
version=1.0.27.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://alsa.cybermirror.org/utils/alsa-utils-1.0.27.2.tar.bz2
nwget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.27.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" alsa-utils-1.0.27.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --disable-alsaconf --disable-xmlto 
make

make install

touch /var/lib/alsa/asound.state 
alsactl store

usermod -a -G audio mao

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-alsa


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-server
version=1.15.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.x.org/pub/individual/xserver/xorg-server-1.15.0.tar.bz2
nwget http://xorg.freedesktop.org/archive/individual/xserver/xorg-server-1.15.0.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/xorg-server-1.15.0-add_prime_support-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" xorg-server-1.15.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../xorg-server-1.15.0-add_prime_support-1.patch

./configure $XORG_CONFIG --with-xkb-output=/var/lib/xkb --enable-install-setuid 
make

make install 
mkdir -pv -pv /etc/X11/xorg.conf.d 
cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

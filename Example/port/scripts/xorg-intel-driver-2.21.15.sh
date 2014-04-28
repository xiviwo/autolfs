#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-intel-driver
version=2.21.15
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/xf86-video-intel-2.21.15-api_change-1.patch
nwget http://xorg.freedesktop.org/archive/individual/driver/xf86-video-intel-2.21.15.tar.bz2
nwget ftp://ftp.x.org/pub/individual/driver/xf86-video-intel-2.21.15.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-video-intel-2.21.15.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../xf86-video-intel-2.21.15-api_change-1.patch 
./configure $XORG_CONFIG --enable-kms-only --with-default-accel=sna 
make

make install

cat >> /etc/X11/xorg.conf << "EOF"
Section "Module"
        Load "dri2"
        Load "glamoregl"
EndSection

Section "Device"
        Identifier "intel"
        Driver "intel"
        Option "AccelMethod" "glamor"
EndSection
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

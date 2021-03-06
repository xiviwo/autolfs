#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-ati-driver
version=7.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/archive/individual/driver/xf86-video-ati-7.3.0.tar.bz2
nwget ftp://ftp.x.org/pub/individual/driver/xf86-video-ati-7.3.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-video-ati-7.3.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG 
make

make install

cat >> /etc/X11/xorg.conf << "EOF"
Section "Module"
        Load "dri2"
        Load "glamoregl"
EndSection

Section "Device"
        Identifier "radeon"
        Driver "radeon"
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

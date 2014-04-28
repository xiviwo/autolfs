#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rxvt-unicode
version=9.19
export MAKEFLAGS='-j 4'
download()
{
nwget http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.19.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" rxvt-unicode-9.19.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-everything 
make

make install

cat >> /etc/X11/app-defaults/URxvt << "EOF"
URxvt*perl-ext: matcher
URxvt*urlLauncher: firefox
URxvt.background: black
URxvt.foreground: yellow
URxvt*font: xft:Monospace:pixelsize=12
EOF

# Start the urxvtd daemon
urxvtd -q -f -o &


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

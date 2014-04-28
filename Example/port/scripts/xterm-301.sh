#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xterm
version=301
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://invisible-island.net/xterm/xterm-301.tgz

}
unpack()
{
preparepack "$pkgname" "$version" xterm-301.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/v0/,+1s/new:/new:kb=^?:/' termcap 
echo -e '\tkbs=\\177,' >> terminfo 

TERMINFO=/usr/share/terminfo ./configure $XORG_CONFIG --with-app-defaults=/etc/X11/app-defaults 

make

make install 
make install-ti

cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

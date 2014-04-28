#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=introduction-to-xorg
version=7.7
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
mkdir -pv xc 
cd xc

export XORG_PREFIX="/opt"

export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"

cat > /etc/profile.d/xorg.sh << "EOF"
XORG_PREFIX="/opt"
XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
chmod 644 /etc/profile.d/xorg.sh

cat >> /etc/profile.d/xorg.sh << "EOF"

pathappend $XORG_PREFIX/bin             PATH
pathappend $XORG_PREFIX/lib/pkgconfig   PKG_CONFIG_PATH
pathappend $XORG_PREFIX/share/pkgconfig PKG_CONFIG_PATH

pathappend $XORG_PREFIX/lib             LIBRARY_PATH
pathappend $XORG_PREFIX/include         C_INCLUDE_PATH
pathappend $XORG_PREFIX/include         CPLUS_INCLUDE_PATH

ACLOCAL='aclocal -I $XORG_PREFIX/share/aclocal'

export PATH PKG_CONFIG_PATH ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
EOF

echo "$XORG_PREFIX/lib" >> /etc/ld.so.conf

sed "s@/usr/X11R6@$XORG_PREFIX@g" -i /etc/man_db.conf

ln -svf $XORG_PREFIX/share/X11 /usr/share/X11

install -v -m755 -d $XORG_PREFIX 
install -v -m755 -d $XORG_PREFIX/lib 
ln -svf lib $XORG_PREFIX/lib64


}
download;unpack;build

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=kde-pre-installation-configuration
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
ln -svf $XORG_PREFIX /usr/X11R6

export KDE_PREFIX=/usr

export KDE_PREFIX=/opt/kde

cat > /etc/profile.d/kde.sh << 'EOF'
# Begin /etc/profile.d/kde.sh

KDE_PREFIX=/opt/kde
KDEDIR=$KDE_PREFIX

pathappend $KDE_PREFIX/bin             PATH
pathappend $KDE_PREFIX/lib/pkgconfig   PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share/pkgconfig PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share           XDG_DATA_DIRS
pathappend /etc/kde/xdg                XDG_CONFIG_DIRS

export KDE_PREFIX KDEDIR

# End /etc/profile.d/kde.sh
EOF


cat >> /etc/ld.so.conf << EOF
# Begin kde addition

/opt/kde/lib

# End kde addition
EOF

install -d $KDE_PREFIX/share 
ln -svf /usr/share/dbus-1 $KDE_PREFIX/share 
ln -svf /usr/share/polkit-1 $KDE_PREFIX/share

mv /opt/kde{,-4.12.2} 
ln -svf kde-4.12.2 /opt/kde


}
download;unpack;build

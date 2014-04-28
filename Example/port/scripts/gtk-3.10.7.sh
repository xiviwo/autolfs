#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gtk
version=3.10.7
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gtk+/3.10/gtk+-3.10.7.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gtk+/3.10/gtk+-3.10.7.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gtk+-3.10.7.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --enable-broadway-backend --enable-x11-backend --disable-wayland-backend 
make

make install

gtk-query-immodules-3.0 --update-cache

glib-compile-schemas /usr/share/glib-2.0/schemas

mkdir -pv -p ~/.config/gtk-3.0 
cat > ~/.config/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Adwaita
gtk-fallback-icon-theme = gnome
EOF

cat > /etc/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Clearwaita
gtk-fallback-icon-theme = elementary
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

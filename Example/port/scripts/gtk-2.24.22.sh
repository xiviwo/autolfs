#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gtk
version=2.24.22
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.22.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.22.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gtk+-2.24.22.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's#l \(gtk-.*\).sgml#& -o \1#' docs/{faq,tutorial}/Makefile.in 
sed -i 's#.*@man_#man_#' docs/reference/gtk/Makefile.in               
sed -i -e 's#pltcheck.sh#$(NULL)#g' gtk/Makefile.in                   
./configure --prefix=/usr --sysconfdir=/etc                           
make

make install

gtk-query-immodules-2.0 --update-cache

cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

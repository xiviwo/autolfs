#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=icewm
version=1.3.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/icewm/icewm-1.3.8.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" icewm-1.3.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/^LIBS/s/\(.*\)/\1 -lfontconfig/' src/Makefile.in 
./configure --prefix=/usr 
make

make install         
make install-docs    
make install-man     
make install-desktop

echo icewm-session > ~/.xinitrc

mkdir -pv ~/.icewm                                       
cp -v /usr/share/icewm/keys ~/.icewm/keys               
cp -v /usr/share/icewm/menu ~/.icewm/menu               
cp -v /usr/share/icewm/preferences ~/.icewm/preferences 
cp -v /usr/share/icewm/toolbar ~/.icewm/toolbar         
cp -v /usr/share/icewm/winoptions ~/.icewm/winoptions

cat > ~/.icewm/menu << "EOF"
prog Urxvt xterm urxvt
prog GVolWheel /usr/share/pixmaps/gvolwheel/audio-volume-medium gvolwheel
separator
menufile General folder general
menufile Multimedia folder multimedia
menufile Tool_bar folder toolbar
EOF 
>cat > ~/.icewm/general << "EOF"
prog Firefox firefox firefox
prog Epiphany /usr/share/icons/gnome/16x16/apps/web-browser epiphany
prog Midori /usr/share/icons/hicolor/24x24/apps/midori midori
separator
prog Gimp /usr/share/icons/hicolor/16x16/apps/gimp gimp
separator
prog Evince /usr/share/icons/hicolor/16x16/apps/evince evince
prog Epdfview /usr/share/epdfview/pixmaps/icon_epdfview-48 epdfview
EOF 
>cat > ~/.icewm/multimedia << "EOF"
prog Audacious /usr/share/icons/hicolor/48x48/apps/audacious audacious
separator
prog Parole /usr/share/icons/hicolor/16x16/apps/parole parole
prog Totem /usr/share/icons/hicolor/16x16/apps/totem totem
prog Vlc /usr/share/icons/hicolor/16x16/apps/vlc vlc
prog Xine /usr/share/pixmaps/xine xine
EOF 

cat > ~/.icewm/startup << "EOF"
rox -p Default &
EOF 
chmod +x ~/.icewm/startup


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

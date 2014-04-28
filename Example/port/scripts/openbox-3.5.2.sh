#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openbox
version=3.5.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://openbox.org/dist/openbox/openbox-3.5.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" openbox-3.5.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
export LIBRARY_PATH=$XORG_PREFIX/lib

./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/openbox-3.5.2 --disable-static                      
make

make install

cp -rf /etc/xdg/openbox ~/.config

ls -d /usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'

echo openbox > ~/.xinitrc

cat > ~/.xinitrc << "EOF"
display -backdrop -window root /path/to/beautiful/picture.jpeg
exec openbox
EOF

cat > ~/.xinitrc << "EOF"
# make an array which lists the pictures:
picture_list=(~/.config/backgrounds/*)
# create a random integer between 0 and the number of pictures:
random_number=$(( ${RANDOM} % ${#picture_list[@]} ))
# display the chosen picture:
display -backdrop -window root "${picture_list[${random_number}]}"
exec openbox
EOF

cat > ~/.xinitrc << "EOF"
. /etc/profile
picture_list=(~/.config/backgrounds/*)
random_number=$(( ${RANDOM} % ${#picture_list[*]} ))
display -backdrop -window root "${picture_list[${random_number}]}"
numlockx
eval $(dbus-launch --auto-syntax --exit-with-session)
lxpanel &
exec openbox
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

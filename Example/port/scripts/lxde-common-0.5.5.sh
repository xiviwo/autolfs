#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lxde-common
version=0.5.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lxde/lxde-common-0.5.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lxde-common-0.5.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -e "s:@prefix@/share/lxde/pcmanfm:@sysconfdir@/xdg/pcmanfm/LXDE:" -i startlxde.in 
./configure --prefix=/usr --sysconfdir=/etc 
make

make install 
install -Dm644 lxde-logout.desktop /usr/share/applications/lxde-logout.desktop

update-mime-database /usr/share/mime 
gtk-update-icon-cache -qf /usr/share/icons/hicolor 
update-desktop-database -q

cat > ~/.xinitrc << "EOF"
ck-launch-session startlxde
EOF

startx


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

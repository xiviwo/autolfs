#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fluxbox
version=1.3.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.jaist.ac.jp/pub//sourceforge/f/fl/fluxbox/fluxbox/1.3.5/fluxbox-1.3.5.tar.bz2
nwget http://downloads.sourceforge.net/fluxbox/fluxbox-1.3.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" fluxbox-1.3.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install

echo startfluxbox > ~/.xinitrc

cat > /usr/share/xsessions/fluxbox.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Fluxbox
Comment=This session logs you into Fluxbox
Exec=startfluxbox
Type=Application
EOF

mkdir -pv ~/.fluxbox 
cp -v /usr/share/fluxbox/init ~/.fluxbox/init 
cp -v /usr/share/fluxbox/keys ~/.fluxbox/keys

cd ~/.fluxbox 
fluxbox-generate_menu

cp -v /usr/share/fluxbox/menu ~/.fluxbox/menu

cp /usr/share/fluxbox/styles/<theme> ~/.fluxbox/theme 
sed -i 's,\(session.styleFile:\).*,\1 ~/.fluxbox/theme,' ~/.fluxbox/init 
echo "background.pixmap: </path/to/nice/image.xpm>" >> ~/.fluxbox/theme


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

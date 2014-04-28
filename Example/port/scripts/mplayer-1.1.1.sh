#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mplayer
version=1.1.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/MPlayer-1.1.1-giflib_fixes-1.patch
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/MPlayer-1.1.1-live_fixes-1.patch
nwget http://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.1.tar.xz
nwget ftp://ftp.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.1.tar.xz
nwget ftp://ftp.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" MPlayer-1.1.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../MPlayer-1.1.1-giflib_fixes-1.patch 
patch -Np1 -i ../MPlayer-1.1.1-live_fixes-1.patch 
sed -i 's:libsmbclient.h:samba-4.0/&:' configure stream/stream_smb.c 

./configure --prefix=/usr --confdir=/etc/mplayer --enable-dynamic-plugins --enable-menu --enable-gui             
make

make install

install -v -m755 -d /usr/share/doc/mplayer-1.1.1 
install -v -m644    DOCS/HTML/en/* /usr/share/doc/mplayer-1.1.1

install -v -m644 etc/codecs.conf /etc/mplayer

install -v -m644 etc/*.conf /etc/mplayer

gtk-update-icon-cache 
update-desktop-database

tar -xvf ../Clearlooks-1.5.tar.bz2 -C /usr/share/mplayer/skins 
ln -sfv Clearlooks /usr/share/mplayer/skins/default


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

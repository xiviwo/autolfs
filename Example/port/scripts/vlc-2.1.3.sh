#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=vlc
version=2.1.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.videolan.org/pub/videolan/vlc/2.1.3/vlc-2.1.3.tar.xz
nwget http://download.videolan.org/pub/videolan/vlc/2.1.3/vlc-2.1.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" vlc-2.1.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's:libsmbclient.h:samba-4.0/&:' modules/access/smb.c 
./bootstrap                                                 
./configure --prefix=/usr                                   
make

make docdir=/usr/share/doc/vlc-2.1.3 install

gtk-update-icon-cache 
update-desktop-database


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

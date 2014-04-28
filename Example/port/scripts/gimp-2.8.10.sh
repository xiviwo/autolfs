#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gimp
version=2.8.10
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://gimp.org/pub/gimp/help/gimp-help-2.8.1.tar.bz2
nwget ftp://ftp.gimp.org/pub/gimp/v2.8/gimp-2.8.10.tar.bz2
nwget http://artfiles.org/gimp.org/gimp/v2.8/gimp-2.8.10.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gimp-2.8.10-device_info-1.patch
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gimp-2.8.10-freetype-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" gimp-2.8.10.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../gimp-2.8.10-device_info-1.patch

patch -Np1 -i ../gimp-2.8.10-freetype-1.patch              
./configure --prefix=/usr --sysconfdir=/etc --without-gvfs 
make

make install

ALL_LINGUAS="ca da de el en en_GB es fr it ja ko nl nn pt_BR ru sl sv zh_CN" ./configure --prefix=/usr 

make

make install 
chown -R root:root /usr/share/gimp/2.0/help

gtk-update-icon-cache 
update-desktop-database

echo '(web-browser "<browser> %s")' >> /etc/gimp/2.0/gimprc


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

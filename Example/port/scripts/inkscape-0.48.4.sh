#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=inkscape
version=0.48.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/inkscape-0.48.4-freetype-1.patch
nwget http://downloads.sourceforge.net/inkscape/inkscape-0.48.4.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/inkscape-0.48.4-gc-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" inkscape-0.48.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../inkscape-0.48.4-gc-1.patch                                    
patch -Np1 -i ../inkscape-0.48.4-freetype-1.patch                              
sed -e "s@commands_toolbox,@commands_toolbox@" -i src/widgets/desktop-widget.h 
./configure --prefix=/usr                                                      
make

make install

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

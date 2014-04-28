#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lynx
version=2.8.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://lynx.isc.org/lynx2.8.8/lynx2.8.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" lynx2.8.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc/lynx --datadir=/usr/share/doc/lynx-2.8.8 --with-zlib --with-bzlib --with-screen=ncursesw --enable-locale-charset 
make

make install-full 
chgrp -v -R root /usr/share/doc/lynx-2.8.8/lynx_doc

sed -i 's/#\(LOCALE_CHARSET\):FALSE/\1:TRUE/' /etc/lynx/lynx.cfg

sed -i 's/#\(DEFAULT_EDITOR\):/\1:vi/' /etc/lynx/lynx.cfg

sed -i 's/#\(PERSISTENT_COOKIES\):FALSE/\1:TRUE/' /etc/lynx/lynx.cfg


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

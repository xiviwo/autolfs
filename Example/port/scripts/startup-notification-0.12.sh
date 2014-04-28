#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=startup-notification
version=0.12
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" startup-notification-0.12.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m644 -D doc/startup-notification.txt /usr/share/doc/startup-notification-0.12/startup-notification.txt


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

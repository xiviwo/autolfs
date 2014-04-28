#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=screen
version=4.0.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz
nwget http://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" screen-4.0.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --infodir=/usr/share/info --mandir=/usr/share/man --with-socket-dir=/var/run/screen --with-pty-group=5 --with-sys-screenrc=/etc/screenrc 

sed -i -e "s%/usr/local/etc/screenrc%/etc/screenrc%" {etc,doc}/* 
make

make install 
install -m 644 etc/etcscreenrc /etc/screenrc


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

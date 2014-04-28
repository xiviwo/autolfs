#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=emacs
version=24.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/pub/gnu/emacs/emacs-24.3.tar.xz
nwget ftp://ftp.gnu.org/pub/gnu/emacs/emacs-24.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" emacs-24.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-gif=no --localstatedir=/var  
make bootstrap

make install 
chown -v -R root:root /usr/share/emacs/24.3

gtk-update-icon-cache -qf /usr/share/icons/hicolor


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

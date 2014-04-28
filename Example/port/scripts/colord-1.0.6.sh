#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=colord
version=1.0.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/colord/releases/colord-1.0.6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" colord-1.0.6.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 71 colord 
useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 -g colord -s /bin/false colord

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-daemon-user=colord --enable-vala --disable-bash-completion --disable-systemd-login --disable-static 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

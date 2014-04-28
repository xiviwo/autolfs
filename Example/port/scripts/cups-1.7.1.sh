#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cups
version=1.7.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.cups.org/software/1.7.1/cups-1.7.1-source.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cups-1.7.1-content_type-1.patch
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cups-1.7.1-blfs-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" cups-1.7.1-source.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp

groupadd -g 19 lpadmin

usermod -a -G lpadmin mao

sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in

patch -Np1 -i ../cups-1.7.1-content_type-1.patch

patch -Np1 -i ../cups-1.7.1-blfs-1.patch 
aclocal -I config-scripts 
autoconf -I config-scripts 

CC=gcc ./configure --libdir=/usr/lib --with-rcdir=/tmp/cupsinit --with-docdir=/usr/share/cups/doc --with-system-groups=lpadmin      
make

make install 
rm -rf /tmp/cupsinit 
ln -svfn ../cups/doc /usr/share/doc/cups-1.7.1

echo "ServerName /var/run/cups/cups.sock" > /etc/cups/client.conf

rm -rf /usr/share/cups/banners 
rm -rf /usr/share/cups/data/testprint

gtk-update-icon-cache

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-cups


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=avahi
version=0.6.31
export MAKEFLAGS='-j 4'
download()
{
nwget http://avahi.org/download/avahi-0.6.31.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" avahi-0.6.31.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -fg 84 avahi 
useradd -c "Avahi Daemon Owner" -d /var/run/avahi-daemon -u 84 -g avahi -s /bin/false avahi

groupadd -fg 86 netdev

sed -i 's/\(CFLAGS=.*\)-Werror \(.*\)/\1\2/' configure 
sed -i -e 's/-DG_DISABLE_DEPRECATED=1//' -e '/-DGDK_DISABLE_DEPRECATED/d' avahi-ui/Makefile.in 
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --disable-mono --disable-monodoc --disable-python --disable-qt3 --disable-qt4 --enable-core-docs --with-distro=none 
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-avahi


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

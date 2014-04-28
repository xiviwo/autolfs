#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bluez
version=4.101
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz
nwget ftp://ftp.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" bluez-4.101.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-bccmd --enable-dfutool --enable-dund --enable-hid2hci --enable-hidd --enable-pand --enable-tools --enable-wiimote --disable-test --without-systemdunitdir 
make

make install

for CONFFILE in audio input network serial ; do
    install -v -m644 ${CONFFILE}/${CONFFILE}.conf /etc/bluetooth/${CONFFILE}.conf
done
unset CONFFILE

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-bluetooth


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

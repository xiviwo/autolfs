#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=linux
version=3.13.3
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" linux-3.13.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make mrproper

make localmodconfig

make

make modules_install

cp -v arch/x86/boot/bzImage /boot/vmlinuz-3.13.3-lfs-7.5

cp -v System.map /boot/System.map-3.13.3

cp -v .config /boot/config-3.13.3

install -d /usr/share/doc/linux-3.13.3
cp -r Documentation/* /usr/share/doc/linux-3.13.3

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=linux
version=3.9.6
echo "Building -------------- linux-3.9.6--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf linux-3.9.6.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make mrproper
make LANG=	<host_LANG_value> LC_ALL= menuconfig
make
make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-3.9.6-lfs-SVN-20130616
cp -v System.map /boot/System.map-3.9.6
cp -v .config /boot/config-3.9.6
install -d /usr/share/doc/linux-3.9.6
cp -r Documentation/* /usr/share/doc/linux-3.9.6
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
# End /etc/modprobe.d/usb.conf
EOF
echo "End of Building -------------- linux-3.9.6--------------"

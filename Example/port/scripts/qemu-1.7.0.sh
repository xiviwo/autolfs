#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qemu
version=1.7.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://wiki.qemu.org/download/qemu-1.7.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" qemu-1.7.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
egrep '^flags.*(vmx|svm)' /proc/cpuinfo

export LIBRARY_PATH=/opt/xorg/lib

sed -e '/#include <sys\/capability.h>/ d' -e '/#include "virtio-9p-marshal.h"/ i#include <sys\/capability.h>' -i fsdev/virtfs-proxy-helper.c 

./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/qemu-1.7.0 --target-list=x86_64-softmmu 
make

make install 
[ -e  /usr/lib/libcacard.so ] && chmod -v 755 /usr/lib/libcacard.so

groupadd -g 61 kvm

usermod -a -G kvm mao

cat > /lib/udev/rules.d/65-kvm.rules << "EOF"
KERNEL=="kvm", NAME="%k", GROUP="kvm", MODE="0660"
EOF

ln -svf qemu-system-x86_64 /usr/bin/qemu




sysctl -w net.ipv4.ip_forward=1

cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward=1
EOF

cat > /etc/qemu-ifup << EOF
#!/bin/bash

switch=br0

if [ -n "\$1" ]; then
  # Add new tap0 interface to bridge
  /sbin/ip link set \$1 up
  sleep 0.5s
  /usr/sbin/brctl addif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi

exit 0
EOF

chmod +x /etc/qemu-ifup

cat > /etc/qemu-ifdown << EOF
#!/bin/bash

switch=br0

if [ -n "\$1" ]; then
  # Remove tap0 interface from bridge
  /usr/sbin/brctl delif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi

exit 0
EOF

chmod +x /etc/qemu-ifdown


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

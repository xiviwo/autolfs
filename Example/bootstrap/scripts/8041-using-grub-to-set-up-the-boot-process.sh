#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=using-grub-to-set-up-the-boot-process
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
:
}
build()
{

grub-mkrescue --output= &&
xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed 

grub-install /dev/vdb

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,2)

menuentry "GNU/Linux, Linux 3.13.3-lfs-7.5" {
        linux   /boot/vmlinuz-3.13.3-lfs-7.5 root=/dev/vda1 ro
}
EOF

}
download;unpack;build

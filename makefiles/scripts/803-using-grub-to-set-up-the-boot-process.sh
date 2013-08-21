#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=using
version=
grub-install /dev/sda
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5
insmod ext2
set root=(hd0,2)
menuentry "GNU/Linux, Linux 3.9.6-lfs-SVN-20130616" {
        linux   /boot/vmlinuz-3.9.6-lfs-SVN-20130616 root=/dev/sda2 ro
}
EOF


Creating_the_etc_fstab_File:
	
cat > /etc/fstab << "EOF"
	# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/<xxx>     /            	<fff>    defaults            1     1
/dev/	<yyy>     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF
	
hdparm -I /dev/sda | grep NCQ

Linux_3_9_6:
	
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


Using_GRUB_to_Set_Up_the_Boot_Process:
	
cd /tmp &&
grub-mkrescue --output=grub-img.iso &&
xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso	
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

MakingtheLFSSystemBootable : Creating_the_etc_fstab_File Linux_3_9_6 Using_GRUB_to_Set_Up_the_Boot_Process 
LFS=/mnt/lfs
SOURCES=$(LFS)/sources
MakingtheLFSSystemBootable : Creating-the-etc-fstab-File Linux-3-9-6 Using-GRUB-to-Set-Up-the-Boot-Process 
Creating-the-etc-fstab-File:
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

Linux-3-9-6:
	cd $(SOURCES) && rm -rf linux-3.9.6
	cd $(SOURCES) && rm -rf linux-build
	cd $(SOURCES) && mkdir -pv linux-3.9.6
	cd $(SOURCES) && tar xvf linux-3.9.6.tar.xz -C linux-3.9.6  --strip-components 1
	cd $(SOURCES)/linux-3.9.6/ && make mrproper
	cd $(SOURCES)/linux-3.9.6/ && make LANG=	<host_LANG_value> LC_ALL= menuconfig
	cd $(SOURCES)/linux-3.9.6/ && make
	cd $(SOURCES)/linux-3.9.6/ && make modules_install
	cd $(SOURCES)/linux-3.9.6/ && cp -v arch/x86/boot/bzImage /boot/vmlinuz-3.9.6-lfs-SVN-20130616
	cd $(SOURCES)/linux-3.9.6/ && cp -v System.map /boot/System.map-3.9.6
	cd $(SOURCES)/linux-3.9.6/ && cp -v .config /boot/config-3.9.6
	cd $(SOURCES)/linux-3.9.6/ && install -d /usr/share/doc/linux-3.9.6
	cd $(SOURCES)/linux-3.9.6/ && cp -r Documentation/* /usr/share/doc/linux-3.9.6
	cd $(SOURCES)/linux-3.9.6/ && install -v -m755 -d /etc/modprobe.d
	cat > /etc/modprobe.d/usb.conf << "EOF"
	# Begin /etc/modprobe.d/usb.conf
	install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
	install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
	# End /etc/modprobe.d/usb.conf
	EOF

Using-GRUB-to-Set-Up-the-Boot-Process:
	grub-install /dev/mapper/loop0
	cat > /boot/grub/grub.cfg << "EOF"
	# Begin /boot/grub/grub.cfg
	set default=0
	set timeout=5
	insmod ext2
	set root=(hd0,1)
	menuentry "GNU/Linux, Linux 3.9.6-lfs-SVN-20130616" {
	linux   /boot/vmlinuz-3.9.6-lfs-SVN-20130616 root=/dev/vda1 ro
	}
	EOF

LFS=/mnt/lfs
SOURCES=$(LFS)/sources
TheEnd : The-End Rebooting-the-System 
The-End:
	echo SVN-20130616 > /etc/lfs-release
	cat > /etc/lsb-release << "EOF"
	DISTRIB_ID="Linux From Scratch"
	DISTRIB_RELEASE="SVN-20130616"
	DISTRIB_CODENAME="MAO"
	DISTRIB_DESCRIPTION="Linux From Scratch"
	EOF

Rebooting-the-System:
	logout
	umount -v $(LFS)/dev/pts
	cd $(SOURCES)/rebooting-/ && if [ -h $(LFS)/dev/shm ]; then
	link=$(readlink $(LFS)/dev/shm)
	umount -v $(LFS)/$(link)
	unset link
	else
	umount -v $(LFS)/dev/shm
	fi
	umount -v $(LFS)/dev
	umount -v $(LFS)/proc
	umount -v $(LFS)/sys
	umount -v $(LFS)
	umount -v $(LFS)/usr
	umount -v $(LFS)/home
	umount -v $(LFS)

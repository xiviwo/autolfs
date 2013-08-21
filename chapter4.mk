LFS=/mnt/lfs
SOURCES=$(LFS)/sources
FinalPreparations : About-LFS Creating-the-LFS-tools-Directory Adding-the-LFS-User Setting-Up-the-Environment About-SBUs 
About-LFS:
	echo $(LFS)
	export LFS=/mnt/lfs

Creating-the-LFS-tools-Directory:
	mkdir -pv $(LFS)/tools
	ln -sv $(LFS)/tools /

Adding-the-LFS-User:
	groupadd lfs
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs
	echo 'lfs:ping' | chpasswd
	chown -Rv lfs $(LFS)/tools
	chown -Rv lfs $(LFS)/sources

Setting-Up-the-Environment:
	cat > ~/.bash_profile << "EOF"
	source ~/.bashrc
	EOF
	cat > ~/.bashrc << "EOF"
	set +h
	umask 022
	LFS=/mnt/lfs
	LC_ALL=POSIX
	LFS_TGT=$(uname -m)-lfs-linux-gnu
	PATH=/tools/bin:/bin:/usr/bin
	export LFS LC_ALL LFS_TGT PATH
	EOF
	source ~/.bash_profile

About-SBUs:
	export MAKEFLAGS='-j 2'
	make -j2

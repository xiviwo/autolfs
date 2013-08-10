
About_LFS:
	
	echo $LFS	
	export LFS=/mnt/lfs

Creating_the_LFS_tools_Directory:
	
	mkdir -v $LFS/tools	
	ln -sv $LFS/tools /

Adding_the_LFS_User:
	
	groupadd lfs
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs	
	passwd lfs	
	chown -v lfs $LFS/tools	
	chown -v lfs $LFS/sources	
	su - lfs

Setting_Up_the_Environment:
	
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
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

About_SBUs:
	
export MAKEFLAGS='-j 2'	
make -j2
FinalPreparations : About_LFS Creating_the_LFS_tools_Directory Adding_the_LFS_User Setting_Up_the_Environment About_SBUs 

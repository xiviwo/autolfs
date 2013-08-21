LFS=/mnt/lfs
SOURCES=$(LFS)/sources
PreparingaNewPartition : Creating-a-File-System-on-the-Partition Mounting-the-New-Partition 
Creating-a-File-System-on-the-Partition:
	mkfs -v -t ext4 /dev/	<xxx>
	mkswap /dev/	<yyy>

Mounting-the-New-Partition:
	export LFS=/mnt/lfs
	mkdir -pv $(LFS)
	mount -v -t ext4 /dev/	<xxx> $(LFS)
	mkdir -pv $(LFS)
	mount -v -t ext4 /dev/	<xxx> $(LFS)
	mount -v -t ext4 /dev/	<yyy> $(LFS)/usr
	/sbin/swapon -v /dev/	<zzz>

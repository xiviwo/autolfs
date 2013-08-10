
Creating_a_File_System_on_the_Partition:
	
mkfs -v -t ext4 /dev/	<xxx>
	
mkswap /dev/	<yyy>


Mounting_the_New_Partition:
	
export LFS=/mnt/lfs	
mkdir -pv $LFS
mount -v -t ext4 /dev/	<xxx> $LFS
	
mkdir -pv $LFS
mount -v -t ext4 /dev/	<xxx> $LFS
mkdir -v $LFS/usr
mount -v -t ext4 /dev/	<yyy> $LFS/usr
	
/sbin/swapon -v /dev/	<zzz>

PreparingaNewPartition : Creating_a_File_System_on_the_Partition Mounting_the_New_Partition 
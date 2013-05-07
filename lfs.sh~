#!/bin/bash

[ $EUID -ne 0 ] && { echo "You are not root!"; exit 1; }
[ $# -ne 1 ] && { echo "Insuffient arguments!"; exit 1; } 
[ ! -b "$1" ] && { echo "Invalid block device!"; exit 1; }
export LFS=/mnt/lfs
export MAKEFLAGS='-j 4'
export home=/home/lfs
firstdev=
seconddev=
DEBUG_="true"
wget_list="http://www.linuxfromscratch.org/lfs/view/stable/wget-list"
md5sums="http://www.linuxfromscratch.org/lfs/view/stable/md5sums"
export sources="$LFS/sources"
export tools="$LFS/tools"
script=$(readlink -f "$0")
export CWD=$(dirname "$script")
source ${CWD}/functions.sh


### partition /dev/XXX 
#if ! file -s "$1" | grep -i partition >/dev/null; then
#fdisk "$1" <<EOF
#n
#p
#1
#
#+19G
#n
#p
#2#


#w
#EOF
#else
#log "There are already existing partitions;no partitioning again!"
#fi

### detect the partion change
#partprobe "$1"

### Find the bigger size of partition
:<< EOF
bldev=${1#/dev/}
debug bldev
bigger=0
for dev in `find /dev -name ${bldev}* | sed "/${bldev}$/d"`
do
	size=$(fdisk -l ${dev} | grep ${dev} | awk '{print $5}' | head -1)
	if [[ $size > $bigger ]]; then
		bigger=$size	
	fi
done


### Decide the device name for primary partition and swap partition, in the form like /dev/mapper/loop0p1
debug bigger
for dev in `find /dev -name ${bldev}* | sed "/${bldev}$/d"`
do
	if fdisk -l ${dev} | grep $bigger >/dev/null; then
	firstdev=${dev}
	debug firstdev
	else if ! fdisk -l ${dev} | grep -w ${bldev} >/dev/null; then
	seconddev=${dev}
	debug seconddev
		fi
	fi
done

### decide whether it needs to format or not, if need, do the job
foundfirst=$(file -sL ${firstdev} | grep -ioE '(ext[2-6]|swap|partition)' | head -1 2>/dev/null)
if [[ -z ${foundfirst} ]]
then
	log "Making ext3 fs for ${firstdev}"
	mkfs.ext3 ${firstdev} >/dev/null
else
	log "${firstdev} already been formatted,will not do it again!"
fi

foundsecond=$(file -sL ${seconddev} | grep -ioE '(ext[2-6]|swap|partition)' | head -1 2>/dev/null)
if [[ -z ${foundsecond} ]] 
then
	log "Making swap fs for ${seconddev}"
	mkswap ${seconddev}
else
	log "${seconddev} already been formatted,will not do it again!"
fi

### Decide whether it needs to mount /mnt/lfs
if ! df -h | grep $LFS >/dev/null; then

	mount -v -t ext3 "${firstdev}" $LFS
	[[ $? -eq 0 ]] && log "${firstdev} is mounted;" 
else 
	log "${firstdev} already been mounted;"
fi

### Decide whether it needs to swapon swap partition 
#if ! swapon -s | grep $(file  ${seconddev} | awk '{print $5}' | sed "s@[\`\.\/\']*@@g") >/dev/null; then

	log "Mount swap : ${seconddev}" 
	swapon -v "${seconddev}"
#else 
#	log "Swap ${seconddev} is mounted already" 
#fi
EOF

### Create source/tools dir and change permissions 
[[ -d $sources ]] && chmod -v a+wt $sources || { mkdir -v $sources; chmod -v a+wt $sources; }

[[ -d $tools ]] && ln -sv "$tools" / || { mkdir -v $tools; ln -sv "$tools" / ; }


#### Begin to download package list, md5sums and packages of course.
log "Download the sources package list... to ${sources}"
wget -nc ${wget_list} -P $sources 2>/dev/null
log "Download the checksum file... to ${sources}"
wget -nc $md5sums -P $sources 2>/dev/null
log "Download all sources packages... to ${sources}"
wget -nc -i $sources/wget-list -P $sources 

cd $sources

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for i in {1..5}
do
	missing=$(md5sum -c $sources/md5sums  2>/dev/null | grep "FAILED" | cut -d":" -f1)
	if [ ! -z $missing ] ; then

		for d in $missing
		do
		miss=$(grep $d $sources/wget-list)
		wget -nc $miss -P $sources 2>/dev/null
		done
		
	else
		break
	fi

done
IFS=$SAVEIFS

### create LFS user
: << TOE
log "Creating LFS Group"

if ! grep lfs /etc/group >/dev/null; then
	
	groupadd lfs
else
	log "LFS Group exists"
fi

log "Creating LFS USER"
if [[ -z $(grep lfs /etc/passwd) ]]; then
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
else
	log "LFS user exists"
fi
log "Changing password for user LFS"
if [[ $(cat /etc/passwd | grep lfs | cut -d":" -f2) = "*" ]]; then
passwd lfs <<EOF
ping
ping
EOF
else
log "Password exists for user LFS"
fi

log "Change ownership of tools and sources"
chown -v lfs $tools
chown -v lfs $sources

log "Logging in with LFS USER"
su - lfs -c "sudo env -i  ${CWD}/lfsbuild.sh"
#sudo su - lfs -c "sudo env -i /home/tomwu/lfsbuild.sh"
TOE


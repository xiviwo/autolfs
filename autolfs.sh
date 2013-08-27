#!/bin/bash
# Version 1.02
# 2013-05-09
# Avoid to user hardcoded func name for BLFS, 
# like Wget_1_14_C15, since it's subject to change anytime 
#

[ $EUID -ne 0 ] && { echo "You are not root!"; exit 1; }
export DEBUG_="true"

[[ ${DEBUG_} = "true" ]] && exec 4> build.log 2>&4 || exec 4> build.log # Redirect STDERR to logfile


unset_env(){

local exlist=""

for arg in $@
do
#echo $arg
exlist+=${arg}"|"
done
#echo ${exlist}
exlist=${exlist%|}
[ -z $exlist ] && exlist="__NOT___"

for a in $(compgen -A function ; compgen -A variable)
do
[[ ${DEBUG_} = "true" ]] && : || echo $a
done

for a in $(compgen -A function ; compgen -A variable)
do
	
	eval "case $a in
	PATH|*BASH*|EUID|PPID|SHELLOPTS|UID|FUNCNAME|COLORTERM)
	#echo $a
	;;
	${exlist})
	#echo list:$a
	;;
	*)
	unset $a;;
	esac"
done 
 }

unset_env EUID 2>/dev/null
#
#unset_env: to clean up all parent env vars,MUST BE RUN BEFORE ANY env variables
#

#exec 4> build.log 2>&4



set -e
#set -o nounset
export LFS=/mnt/lfs
export script=$(readlink -f "$0")
export CWD=$(dirname "$script")
export MAKEFLAGS='-j 4'
export TERM=xterm
[[ $(whoami) = "root" ]] && export HOME=/root || export HOME="/home/"$(whoami) #/home/lfs/.xinitrc: No such file or directory, Setting_Up_the_Environment_C4 fail, decide ~ stand for 
export SHELL=/bin/bash
export PS1='\u:\w\$ '
#############WILL CHANGE IN NEW SYSTEM#################
export username="mao"
export newuser="mao"
export hostdev="/dev/loop0"
export hostfirstdev="/dev/mapper/loop0p1"
export firstdev="vda1"
export seconddev="vda2" 
export diskdev="vda"
export IP="192.168.122.12"
export GATEWAY="192.168.122.2"
export BROADCAST="192.168.122.255"
export nameserver="192.168.122.2 192.168.122.1"
#############WILL CHANGE IN NEW SYSTEM#################
[ $(uname -m) = 'x86_64' ] && ABI=64 || ABI=32
export udevversion=$(/sbin/udevadm --version)
export paper_size="A4"
export HOSTNAME="ALFS"
export domain="ibm.com"
export timezone="Asia/Shanghai"
export LANG="en_US.utf8"
export LANGUAGE=${LANG}
export LC_ALL=C
export PASSWORD="ping"
export KEYMAP="us"
export FS="ext3"
export wget_list="http://www.linuxfromscratch.org/lfs/view/stable/wget-list"
export md5sums="http://www.linuxfromscratch.org/lfs/view/stable/md5sums"
export sources=$LFS/sources
export CMDS=${CWD}/cmds.sh
export FUNCTIONS=${CWD}/functions.sh
export wgetlist=${sources}/"wget-list"
export md5file=${sources}/"md5sums"
export logdir=${sources}/logs
#sources="$LFS/sources"
#CMDS=${CWD}/cmds;  FUNCTIONS=${CWD}/functions.sh;} || {  CMDS=${LFSBUILD}/cmds;  FUNCTIONS=${LFSBUILD}/functions.sh;} 
export SUCCESS=${sources}/"LFSSUCCESS"
source ${FUNCTIONS} 
source ${CMDS} 
export tmp=${sources}/killpid
mkdir -pv $sources
mkdir -pv ${logdir}
touch $SUCCESS
[ -f "$LFS/etc/profile" ] && export PKG_CONFIG_PATH=/opt/lib/pkgconfig:/opt/share/pkgconfig:/usr/lib/pkgconfig
[ -f "$LFS/etc/profile" ] && export LIBRARY_PATH="/lib64:/lib:/usr/lib:/opt/lib"
[ -f "$LFS/etc/profile" ] && source "$LFS/etc/profile"
[ -f "$LFS/etc/profile.d/xorg.sh" ] && source "$LFS/etc/profile.d/xorg.sh"
[ -f "$LFS/etc/profile.d/kde.sh" ] && source "$LFS/etc/profile.d/kde.sh"
[ -f "$LFS/etc/profile.d/qt.sh" ] && source "$LFS/etc/profile.d/qt.sh" 
[ -f "$LFS/etc/profile" ] && export KDE_PREFIX=/opt/kde
[ -f "$LFS/etc/profile" ] && export C_INCLUDE_PATH=/opt/include:/usr/include
[ -f "$LFS/etc/profile" ] && export QMAKE_INCDIR_X11=/opt/include:/usr/include
[ -f "$LFS/etc/profile" ] && export QMAKE_LIBDIR_X11="/lib64:/lib:/usr/lib:/opt/lib:/opt/qt/lib "

trap "cleanup $? $LINENO" 0 1 2 3 13 15 ERR

cleanup(){

exec 3<&1

local exit_status=${1:-$?}
local lineno=$2
local inIFS=$IFS
IFS=$(echo -en "\n\b")
for pid in $(cat $tmp 2>/dev/null )
do
	kill -9  $pid || true
done
IFS=$inIFS
rm -f $tmp
echo Exiting $0 with $exit_status at line $lineno
exit $exit_status
exec 3>&1
}  

# To export all function to child process, MUST BE RUN after all other functions!!!
export_func(){

for func in $(declare -F | cut -d' ' -f3)
do
	if [ ! -z "$func" ] ;then
	export -f $func >/dev/null
	fi
done

}


is_success(){

local func=$1
[ ! -f "$SUCCESS" ] && { touch "$SUCCESS";chown -v lfs.lfs "$SUCCESS"; return 1 ; }

if grep "$func" "$SUCCESS" >/dev/null ; then
return 0
else 
return 1
fi

}



success_build(){
local func=$1
if [ $? == "0" ]  ; then
echo "$func" >> "$SUCCESS"
fi

}
PreparingVirtualKernelFileSystems(){
if ! grep "$FUNCNAME" "$SUCCESS" ; then

Preparing_Virtual_Kernel_File_Systems_C6 || true

success_build $FUNCNAME
else
	log "$FUNCNAME built/run,skip"
fi
}

download_packages(){


local sources="${1}"

if ! is_success $FUNCNAME ; then
	
	mkdir -pv ${sources}
	chmod -v a+wt ${sources}

	#### Begin to download package list, md5sums and packages of course.
	log "Download the sources package list... to ${sources}"
	progress wget -nc ${wget_list} -P ${sources}
	log "Download the checksum file... to ${sources}"
	progress wget -nc $md5sums -P ${sources}
	log "Download all sources packages... to ${sources}"
	progress wget --no-check-certificate -nc -i ${sources}/wget-list -P ${sources} 

	cd ${sources} 

	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for i in {1..5}
	do
		missing=$(md5sum -c ${sources}/md5sums   >&4 | grep "FAILED" | cut -d":" -f1)
		if [ ! -z $missing ] ; then

			for d in $missing
			do
			miss=$(grep $d ${sources}/wget-list)
			progress wget -nc $miss -P ${sources} 
			done
		
		else
			break
		fi

	done
	IFS=$SAVEIFS
	success_build $FUNCNAME
else 
	log "${FUNCNAME} built, skip"
fi

}
mk_working_dir(){

if ! grep $FUNCNAME ${SUCCESS} >/dev/null; then
	
	log "Create ${LFSBUILD} "

	[ ! -d ${LFSBUILD} ] && mkdir -pv ${LFSBUILD}
	#mkdir -pv ${LFSBUILD}
	

	log "copy nessary files to ${LFSBUILD}" 

	cp -fv ${CWD}/cmds ${CWD}/functions.sh "${CWD}/$0" ${LFSBUILD}
	chmod -v +x ${LFSBUILD}/$0
	#ln -sfv "${SUCCESS}" ${LFSBUILD}
	[ ! -f ${SUCCESS} ] &&  touch ${SUCCESS}
	chown -Rv lfs.lfs ${LFSBUILD}
	[[ ${DEBUG_} = "true" ]] || success_build $FUNCNAME
else
	log "$FUNCNAME built,skip"
fi

}


chapterinstall(){

	local CHAPTER=$1
	local sources=$2

	local SUCCESS=${sources}/"LFSSUCCESS"
	debug CHAPTER
	debug sources
	debug SUCCESS
[ ! -d $sources ] && error 1  DIRNOTEXISIT "$sources not exists! "
[ ! -f $SUCCESS ] && error 1  PROGRESSMISS "$SUCCESS missing !"



if ! is_success "$CHAPTER" ; then
	local SAVEIFS=$IFS
	IFS=$(echo -en " \t\n\b")
	for func in $(eval echo \$$CHAPTER)
	do	
		
		case "$func" in
		Preparing_Virtual_Kernel_File_Systems_C6|Package_Management_C6|*Chroot*|Cleaning_Up_C6|Changing_Ownership_C5|Rebooting_the_System_C9|About_Devices_C3)
		log "Will not run $func,skipped"
		continue ;;
		*)

		;;
		esac 
	
		successpack="${func}"
		debug func
		debug successpack
		
		
		time pack_install "$successpack" "${sources}" # || error 1  PACKBUILDFAILURE "$successpack failed to build in $FUNCNAME"
		

		#log " Leaving ${PWD} and back to ${sources}"
		#cd ${sources}


	
	done
	IFS=$SAVEIFS
	success_build $CHAPTER
else
log "Chapter :$CHAPTER been built,skip"
fi
}
remove_previous(){
local folder="$1"

[ -d "$folder" ] && { log "Previous "$folder" exists,removing"; progress rm -rf "$folder" || error 1  DIRREMOVEFAILURE "Failed to remove '$folder'" ; }
return 0

}
trim_pack(){
local packstr="$1"

echo $packstr | sed 's/\.tar.*$\|\.tgz$\|\.zip$//'

}
untar(){

local package="$1"
local sources="$2"

[ ! -z "$package" ] || error 1  NULLPACKSTR "Package name is null"
[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"

packfolder=$(trim_pack ${package})

mkdir -pv $packfolder || error 1  CANNTCREATDIR "Cannot create dir: $packfolder "
case $package in 
	*.zip)
	type unzip || error 2 COMMANDNOTFOUND "Command unzip not found"
	unzip -x "$package" -d "$packfolder"
	;;
	*tar)
	[ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf "$package" -C "$packfolder" --checkpoint=100 --checkpoint-action=dot ; echo -e "\n"; }
	;;
	*)
	 [ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf "$package" -C "$packfolder"  --strip-components 1 --checkpoint=100 --checkpoint-action=dot ; echo -e "\n"; } 
	;;
esac

}

locate_folder(){

local sources="$1"
local packstr="$2"

[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package name is null"
[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"

echo $(find "$sources" -maxdepth 1  -iname $packstr"*" -type d | head -1)

}

into_folder(){

local folder="$1"

	[ -d "$folder" ] && { log "Entering ${folder}"; cd $folder; } || error 1  DIRNOTEXIST "Directory not exists"

}

find_pack_pre(){

local sources="$1"
local packstr="$2"

[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"
[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package name is null"

package=$(find "$sources" -maxdepth 1 -iname ${packstr}"*".xz -o -iname ${packstr}"*".bz2 -o -iname ${packstr}"*".gz -type f | head -1)

echo "$package"

#[ -z "$package" ] && return 1 || return 0 

}

find_pack(){

local sources="$1"
local packstr="$2"

 [ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"
 [ -s "$wgetlist" ] || error 1  WGETLISTMISSING " wget-list is empty!"
 [ ! -z "$packstr" ] || error 1  NULLPACKSTR   "Package name is null"


package=$(grep -iEo  "/$packstr[^/]*\.tar\.((bz2)|(xz)|(gz))$" "$wgetlist")

package="${sources}"${package}

[ -f "$package" ] && echo "$package" || echo ""

}


run_cmdstr(){

		local cmdstr="$1"
		
		log "Building ${cmdstr} "
		local inIFS=$IFS
		IFS=$(echo -en " \t\n\b") # $XORG_CONFIG display incorrectly
		type ${cmdstr} | sed "/${cmdstr}/d" | head -50
	
		case  "$cmdstr" in
		*Stripping*|Creating_the_LFS_tools_Directory_C4|Creating_Directories_C6|Creating_Essential_Files_and_Symlinks_C6|Preparing_Virtual_Kernel_File_Systems_C6|Stripping_Again_C6|Creating_Custom_Symlinks_to_Devices_C7|Introduction_to_Xorg*|Adding_the_LFS_User_C4)
		time progress ${cmdstr} || true ;;
		Xorg_Drivers_C*)
		;;
		Linux_*_*_*_C8|Tripwire*)
		time ${cmdstr} ;;
		*)
		time progress ${cmdstr}   ;; #|| return 1 ;;
		esac 
		IFS=$inIFS

		return 0
}

build_dependency(){

	local func="$1"
	local sources="$2" 
 

	[ ! -z "$func" ] || error 1  NULLPACKSTR "Package name is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	#[ ! -z "$CHAPTER" ] || error 1  NULLSTR "CHAPTER name is null"

	
	local depend_func=${func}"_required_or_recommended"
	local func_list="$(eval echo \$$depend_func)"
	local SAVEIFS=$IFS
	IFS=$(echo -en " \t")
	for dependfunc in  $func_list
	do
	block "Building dependency : $dependfunc for $func" 
	time pack_install $dependfunc "$sources"  #  || error 1  PACKBUILDFAILURE "$dependfunc failed to build in $FUNCNAME"

	done
	IFS=$SAVEIFS
	 [[ -z "$func_list" ]] && log "No dependening  packages for $func" || block "$func"
	
}
get_pack_header(){

local func="$1"
[ ! -z "$func" ] || error 1  NULLPACKSTR "Package name is null"

		
		case "${func}" in
			*systemd* ) packstr="systemd" ;;
			*)
			packstr=$(echo "${func,,}" |  grep -E -o '^[a-zA-Z0-9]+(_[a-zA-Z]+)?'  | sed 's/_/-/' )
			;;
		esac
		echo $packstr
}
do_cleanup_untar_stuff(){

	local package="$1"
	local sources="$2"
	local packstr="$3"

	[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package header is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	[ ! -z "$package" ] || error 1  NULLPACKNAME "Package name is null"

	buildfolder=${sources%/}"/"${packstr}"-build"
	prefolder=$(trim_pack ${package})
	newfolder=$prefolder

	remove_previous "$buildfolder" 
	case "$packstr" in 
		linux)
		[ ! -d "$prefolder"  ] && untar "$package" "$sources"
		;;
		*)
		remove_previous "$prefolder" 

		untar "$package" "$sources"
		;;
	esac

	into_folder "$newfolder"

}
cleanup_after_built(){
	local package="$1"
	local sources="$2"
	local packstr="$3"

	[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package header is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	[ ! -z "$package" ] || error 1  NULLPACKNAME "Package name is null"

	buildfolder=${sources%/}"/"${packstr}"-build"
	prefolder=$(trim_pack ${package})
	

	 
	[ -d "$buildfolder" ] && { log "Previous $buildfolder exists,removing"; rm -rf "$buildfolder" || error 1  DIRREMOVEFAILURE "Failed to remove '$buildfolder'" ; }
	
	[ -d "$prefolder" ] && { log "Previous $prefolder exists,removing"; rm -rf "$prefolder" || error 1  DIRREMOVEFAILURE "Failed to remove '$prefolder'" ; }

}

post_download(){

	local pack="$1"
	local sources="$2" 


	[ ! -z "$pack" ] || error 1  NULLPACKSTR "Package name is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	
	local pack_link=${pack}"_download"

	local SAVEIFS=$IFS
	IFS=$(echo -en " \t")
	for link in  $(eval echo \$$pack_link) 
	do
	 
	log "Download ${link} to ${sources}"

	wget --no-check-certificate -nc --timeout=60 --tries=5 "$link"  -P "${sources}" || true

	done
	IFS=$SAVEIFS
	
}

pack_install(){
		#GCC_4_7_2_C6
		local successpack="$1"
		local sources="$2" 
		#local CHAPTER=$3

		[ ! -z "$successpack" ] || error 1  NULLPACKSTR "Package name is null"
		[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
		#[ ! -z "$CHAPTER" ] || error 1  NULLSTR "CHAPTER name is null"

		into_folder "$sources"



		if ! is_callable "$successpack" ;then 
			log "$successpack is not defined,skipped"
		else

			if ! is_success "$successpack"  ; then # 
				block $successpack

				build_dependency "$successpack" "$sources"  

				packvar=${successpack}"_packname"
				packname=$(eval echo \$$packvar)
				if [ ! -z $packname ] ; then 
					package="${sources}""/"$packname
					packname=$(trim_pack ${packname})
					packstr=$(get_pack_header ${packname})
					local pack_link=${successpack}"_download"
			
					if [ ! -z "$(eval echo \$$pack_link)" ] ; then
						post_download $successpack "$sources" 
					
						[ ! -z $packname ] && [ -f  "$package" ] || error 1  PACKMISSING "Can't find package locally and download fails too!!"
					
					fi
				else	

					packstr=$(get_pack_header "$successpack")
	
					package=$(find_pack "$sources"  "${packstr}" )
				
					#[ ! -z $packstr ] && [ ! -f  "$package" ] && error 1  PACKMISSING "Can't find package locally, you may not download previously"

				
				fi

				[ -f  "$package" ] && do_cleanup_untar_stuff  "$package" "$sources" "$packstr"

				case "$successpack" in
				OpenSSL*|NSS*|WebKitGTK*|NSS*|mdadm*|zsh*)
				export MAKEFLAGS='-j 1'
				;;
				*)
				export MAKEFLAGS='-j 4'
				;;
				esac
				#block "$MAKEFLAGS"
				run_cmdstr ${successpack} #|| error 1  PACKBUILDFAILURE "${successpack} failed to build in $FUNCNAME" 

				[ ! -z "$package" ] && log "${package} building Complete!" || log "${successpack} running Complete!"

				[ -f  "$package" ] && cleanup_after_built "$package" "$sources" "$packstr"
		
				[[ "$successpack" = "BLFS_Boot_Scripts_C2" ]] || success_build $successpack
			else
				log "$successpack been built, skipped"
			 
			fi
		fi
}

prechroot(){

 
local cmdline=""

if [ $# -eq 0 ] ; then
	while read -r line
	do 
	if [ ! -z "$line"   ]; then
	cmdline+=$line
	cmdline+=";"
	fi
	done
	
else
	cmdline="$1"
fi

CHROOT=$(type chroot | cut -d' ' -f3)

"$CHROOT" "$LFS" /tools/bin/env \
    HOME=/root                  \
    TERM="$TERM"                \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h -c "$cmdline"

}

bootstrapchroot(){

local cmdline=""

if [ $# -eq 0 ] ; then
	while read -r line
	do 
	if [ ! -z "$line"   ]; then
	cmdline+=$line
	cmdline+=";"
	fi
	done
	
else
	cmdline="$1"
fi

CHROOT=$(type chroot | cut -d' ' -f3)

"$CHROOT" "$LFS" /usr/bin/env  \
    HOME=/root TERM="$TERM"  \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login -c "$cmdline"

}

parse_book(){

if ! is_success $FUNCNAME ; then


[ ! -s "${CMDS}" ] && { log "Parsing online LFS book and generating ${CMDS}"; python ${CWD}/parsebook.py >&4; } || log "Will not parse LFS book, as ${CMDS} exists."
[ ! -s "${CMDS}" ] && error 1  CMDSMISS "Online LFS Book parse fail!"

#log "Modify generated ${CMDS} according to actual requirement"

exec 3>&1 
#exec >&4

#time part1
#time part2
echo "this ia test "

exec 1>&3

[[ ${DEBUG_} = "true" ]] ||  success_build $FUNCNAME
else
log "$FUNCNAME built/ran,skipped"
fi


}
	
print_progress(){
	  
	  echo "Running :${BOLD}${REVERSE} $* ${OFF},Please wait: "
	  while true
	  do
	    echo -n "#"
	    sleep 1
	  done

}

progress(){

local func=$1


print_progress $* & echo $! >>$tmp

if id "lfs" >/dev/null 2>&1 ; then
	chown -v lfs $tmp >&4 2>&1
else
	chown -v 0 $tmp >&4 2>&1
fi

disown
MYSELF=$!
trap "echo ' Catch CTRL+c ,exiting...' >&3 ;cleanup 1 $LINENO;" INT
echo ""

if ! is_callable "$successpack" ;then 
	$* >&4
else
	$* > "${logdir}"/"$*".log 2>&1 
fi


kill $MYSELF >/dev/null 2>&1 && sed -i "/$MYSELF/d" $tmp
echo  ""
return 0
}

restart_or_not(){
[ -z "$BLFSCHAPTERS" ] && RESUMEFLAG="C9_TheEnd" || RESUMEFLAG="C47_Typesetting"

if is_success  $RESUMEFLAG ;then
log "Looking like previous build had been done; Restart a new build ?"

echo "Choose (yes/no): "
	if read -n 1 -t 10  answer ; then
		case $answer in
		Y|y|yes)
			debug "Empty $SUCCESS to restart"
			>"$SUCCESS"
			rm -f "$wgetlist"
			rm -f "$md5file"
			rm -f "$tmp"
			;;
		N|n|no) 
			exit 0;;
		*) 
			echo "Incorrect input"
			exit 1;;
		esac
	else 
	echo "Time out!exit"
	exit 0
	fi
fi


}

mount_lfs_and_virtual(){

#&& [ $(cat "$SUCCESS" | wc -l) -gt 0 ]

if  ! grep "${LFS}/dev"  /proc/mounts ; then 

log "Looking like $LFS not mounted, mounting $LFS and Virtual Kernel File system"

exec 3<&2
Mounting_the_New_Partition_C2 || true 
Preparing_Virtual_Kernel_File_Systems_C6 || true #; }  || error 1 CANNOTMOUNT "Cannot mount $LFS"
exec 3>&1
fi

}

SuInstall(){

local ch=$1
local sources=$2 
chown -v lfs.lfs "$SUCCESS"

[ ! -f "$tmp" ] && { touch "$tmp"; chown -v lfs.lfs "$tmp"; }

chown -Rv lfs.lfs "$sources" >&4 

#########do NOT use su - lfs#################
su lfs /bin/bash -c  "ConstructingaTemporarySystem $ch ${sources}"
#########do NOT use su - lfs#################

}

find_child_pid(){

    curPid=$1
    childPids=$(ps -o pid --no-headers --ppid ${curPid} || true)
  
    debug childPids 
    echo $curPid >>$tmp
    #cat $tmp
    if [ ! -z "$childPids" ] ; then
	    for childPid in $childPids
	    do
		find_child_pid  $childPid
	    done
    else
         return 0
    fi
}
blockid(){
block "$(id)"
}

blockpwd(){
block "$(pwd)"
}

blockscript(){
block "$script"
}
ConstructingaTemporarySystem(){
local ch=$1
local sources=$2
export HOME=/home/lfs
set -xve 
env HOME=$HOME TERM=$TERM bash -c "intoTemporarySystem $ch ${sources}" 
return 0

}

intoTemporarySystem(){
local ch=$1
local sources=$2

set -xve 
source ~/.bashrc
blockid
blockpwd
blockscript

chapterinstall $ch ${sources}

}
InstallSystem(){

local ch=$1
local sources=$2

setup_env
chapterinstall $ch  "${sources}"

}
setup_env(){
echo ${DEBUG_}
[[ ${DEBUG_} = "true" ]] && set -xve || set -e
[[ ${DEBUG_} = "true" ]] && blockid
[[ ${DEBUG_} = "true" ]] && blockpwd
[[ ${DEBUG_} = "true" ]] && blockscript
[[ ${DEBUG_} = "true" ]] && block "$PKG_CONFIG_PATH"
export SUCCESS=${sources}/"LFSSUCCESS"
export tmp=${sources}/killpid
export wgetlist=${sources}/"wget-list"
export logdir=${sources}/logs
export HOME=/root
#[[ $(whoami) = "root" ]] && export HOME=/root || export HOME="/home/"$(whoami) 
#[ -z "$BLFSCHAPTERS" ] && [ ! -f "/etc/profile.d/xorg.sh" ] &&  { cd ${sources};type Introduction_to_Xorg_7_7_C24; Introduction_to_Xorg_7_7_C24 || true ; source "/etc/profile.d/xorg.sh" ;} || true

}

InstallSpecificPack()
{
local pack=$1
local sources=$2
local ch=$3

setup_env

pack_install $pack  "$sources" 

}
bookinstall(){

local inIFS=$IFS
IFS=$(echo -en " \t\n\b")
for ch in $LFSCHAPTERS $BLFSCHAPTERS 
do
	
	block $ch
	case $ch in
		C0_Preface)
		chapterinstall $ch "${sources}" 
		;;
		C1_Introduction|C2_PreparingaNewPartition)
		log "Chapter: $ch is skipped"
		;;
		C3_PackagesandPatches)
		download_packages ${sources}
		;;
		C4_FinalPreparations)
		
		chapterinstall $ch  ${sources}
		;;
		C5_ConstructingaTemporarySystem) 
		SuInstall $ch ${sources} 
		;;
		C6_InstallingBasicSystemSoftware)
		PreparingVirtualKernelFileSystems
		prechroot "InstallSystem $ch '/sources' "
		;; 
		C7_SettingUpSystemBootscripts) 
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		C8_MakingtheLFSSystemBootable)
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		C9_TheEnd)
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		*)
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
	esac
done
IFS=$inIFS

}
install_openssh(){

post_download "Wget_1_14_C15" "/mnt/lfs/sources"
post_download "OpenSSL_1_0_1e_C4" "/mnt/lfs/sources"
time bootstrapchroot 'InstallSpecificPack "Wget_1_14_C15" "/sources"'
time bootstrapchroot 'InstallSpecificPack "OpenSSH_6_1p1_C4" "/sources" '

}

parse_book 

mount_lfs_and_virtual

restart_or_not

time export_func 2>/dev/null

bookinstall

#post_download "LVM2_2_02_98_C5" "/mnt/lfs/sources"
#post_download "Wget_1_14_C15" "/mnt/lfs/sources"
#post_download "OpenSSL_1_0_1e_C4" "/mnt/lfs/sources"
#time bootstrapchroot 'InstallSpecificPack "Wget_1_14_C15" "/sources"'
#time bootstrapchroot 'InstallSpecificPack "About_initramfs_C5" "/sources"'


#time bootstrapchroot 'InstallSpecificPack "OpenSSL_1_0_1e_C4" "/sources"'
#post_download "OpenSSL_1_0_1e_C4" "/mnt/lfs/sources"
#time bootstrapchroot 'InstallSpecificPack "OpenSSH_6_1p1_C4" "/sources" '

#InstallSpecificPack "DocBook_utils_0_6_14_C44" "/sources"
#InstallSystem 'C4_Security' '/sources'
#chapterinstall 'C24_XWindowSystemEnvironment' '/sources'
#bootstrapchroot  "InstallSystem 'C33_XfceDesktop' '/sources' "

#pack_install "Linux_3_8_1_C8" "${sources}"
#pack_install "shared_mime_info_1_1_C25" "${sources}"
#pack_install "Xorg_Evdev_Driver_2_8_0_C24" "${sources}"
#pack_install "SQLite_3_7_16_1_C22" "${sources}"
#chapterinstall "C3_AfterLFSConfigurationIssues" "$sources"
#chapterinstall "C27_Introduction" "$sources"
#pack_install "ATK_2_6_0_C25" "/sources"
#pack_install "Vala_0_18_1_C13" "/sources"

#pack_install "gobject_introspection_1_34_2_C9" "/sources"
#block $LIBRARY_PATH
#chapterinstall 'C33_XfceDesktop' '/sources'
#chapterinstall "C28_TheKDECore" "$sources"
#chapterinstall "C30_GNOMECorePackages" "$sources"
cleanup 0 $LINENO
exit 0



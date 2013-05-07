#!/bin/bash
set -e
LFS=/mnt/lfs
LFSBUILD=$LFS/lfsbuild
MAKEFLAGS='-j 4'
DEBUG_="true"
sources="$LFS/sources"
tools="$LFS/tools"
script=$(readlink -f "$0")
CWD=$(dirname "$script")
HOME=/home/lfs
TERM=xterm
PS1='\u:\w\$'
IP="192.168.122.10"
GATEWAY="192.168.122.1"
BROADCAST="192.168.122.255"
CMDS=${CWD}/cmds
FUNCTIONS=${CWD}/functions.sh
paper_size="A4"
HOSTNAME="ALFS"
domain="ibm.com"
nameserver="192.168.122.1 192.168.122.2"
timezone="Asia/Shanghai"
LANG="en_US.utf8"
SUCCESS=${sources}/"LFSSUCCESS"
PASSWORD="ping"
KEYMAP="US"
firstdev="vda1"
seconddev="vda2" 
diskdev="vda"
FS="ext3"

source ${FUNCTIONS}
trap onexit 1 2 3 15 ERR

log "Parsing online LFS book"
[ ! -f ${CMDS} ] && python ${CWD}/parsebook.py

log "Change Parameter according to need"

sed -i "s/PAGE=<paper_size>/PAGE=${paper_size}/" ${CMDS}
sed -n "/${paper_size}/p" ${CMDS}

safe_pattern=$(printf '%s\n' "$timezone" | sed 's/[[\.*^$/]/\\&/g')
# now you can safely do
sed -i "s/remove-destination \/usr\/share\/zoneinfo\/<xxx>/remove-destination \/usr\/share\/zoneinfo\/${safe_pattern}/ " ${CMDS}
sed -n "/${safe_pattern}/p" ${CMDS}


sed -i 's/<[xxx|yyy|zzz]*>//'  ${CMDS}

sed -n '/<[xxx|yyy|zzz]*>/p'  ${CMDS}

sed -i "s/HOSTNAME=<lfs>/HOSTNAME=${HOSTNAME}/" ${CMDS}
sed -n "/${HOSTNAME}/p" ${CMDS}

sed -i "s/BROADCAST=[0-9]*.[0-9]*.[0-9]*.[0-9]*/BROADCAST=${BROADCAST}/" ${CMDS}
sed -n "/BROADCAST=/p" ${CMDS}

sed -i "s/IP=[0-9]*.[0-9]*.[0-9]*.[0-9]*/IP=${IP}/" ${CMDS}
sed -n "/IP=/p" ${CMDS}

sed -i "s/GATEWAY=[0-9]*.[0-9]*.[0-9]*.[0-9]*/GATEWAY=${GATEWAY}/" ${CMDS}
sed -n "/GATEWAY=/p" ${CMDS}

sed -i "s/domain <Your Domain Name>/domain ${domain}/ " ${CMDS}
sed -n "/domain/p" ${CMDS}

#sed -i '/nameserver <IP address of your primary nameserver>/d' ${CMDS}
#sed -i '/nameserver <IP address of your secondary nameserver>/d' ${CMDS}

sed -i "/nameserver /d" ${CMDS}

for nserver in $(echo ${nameserver} | sort -rn)
do
echo $nserver
#sed -i "/nameserver /d" ${CMDS}
sed -i "/domain ${domain}/a nameserver $nserver" ${CMDS}
done


#sed -i "N;N;s/\n<IP address of your primary nameserver>/ ${nameserver}/ " ${CMDS}
sed -n "/nameserver/p" ${CMDS}

#sed -i "N;s/\n<IP address of your secondary nameserver>/ ${nameserver}/ " ${CMDS}
#sed -n "/${nameserver}/p" ${CMDS}grep Error glibc-check-log

sed -i "s/LANG=<host_LANG_value>/LANG=${LANG}/ " ${CMDS}
sed -n "/make LANG=/p" ${CMDS}

sed -i "/locale -a/d" ${CMDS}
sed -i "/LC_ALL=<locale name>/d" ${CMDS}
sed -n "/LC_ALL=<locale name>/p" ${CMDS}

sed -i "s/export LANG=<ll>_<CC>.<charmap><@modifiers>/export LANG=${LANG}/" ${CMDS}
sed -n "/export LANG=/p" ${CMDS}

sed -i '/make.*[^_]check\|make.*[^_]test/d' ${CMDS}
sed -n '/make.*[^_]check\|make.*[^_]test/p' ${CMDS}

sed -i '/exec[ ]*[\/tools]*\/bin\/bash[ ]*--login[ ]*+h/d' ${CMDS}

sed -i '/su nobody -s \/bin\/bash \\/d' ${CMDS}
sed -n '/su nobody -s \/bin\/bash \\/p' ${CMDS}
sed -i '/gmp-check-log/d' ${CMDS}
sed -i '/glibc-check-log/d' ${CMDS}
sed -i '/ABI=32/d' ${CMDS} 
sed -i 's/^\.\/configure --prefix=\/usr --enable-cxx$/ABI=64 &/' ${CMDS}
sed -n '/ABI=/p' ${CMDS}

sed -i '/pushd testsuite/,/popd/d' ${CMDS}

sed -i "/passwd root$/ {s/$/ << EOF/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/EOF/}" ${CMDS}
sed -n '/passwd root/ {N;N;N;N;p} ' ${CMDS}

sed -i "/vim -c ':options'/d" ${CMDS}
sed -n "/vim -c/p" ${CMDS}
sed -i "/logout/d" ${CMDS}
sed -n "/logout/p" ${CMDS}
sed -i '/chroot $LFS/,/--login/d' ${CMDS}
sed -n '/chroot $LFS/,/--login/p' ${CMDS}

sed -i '/127.0.0.1 localhost/d' ${CMDS}
sed -i '/<192.168.1.1> <HOSTNAME.example.org>/d' $CMDS

sed -i "s/127.0.0.1 <HOSTNAME.example.org> <HOSTNAME> localhost/127.0.0.1 ${HOSTNAME} localhost/" $CMDS

sed -i "/${IP}[ \t]*${HOSTNAME}/d" $CMDS
sed -i "/127.0.0.1 ${HOSTNAME} localhost/a ${IP}	${HOSTNAME}" $CMDS
sed -n "/127.0.0.1/p" $CMDS
sed -n "/${IP}[ \t]*${HOSTNAME}/p" $CMDS

sed -i "s/KEYMAP=\"de-latin1\"/KEYMAP=\"${KEYMAP}\"/"  $CMDS

sed -i '/KEYMAP_CORRECTIONS="euro2"/d' $CMDS
sed -i '/LEGACY_CHARSET="iso-8859-15"/d' $CMDS
sed -i '/FONT="LatArCyrHeb-16 -m 8859-15"/d' $CMDS

sed -n "/UNICODE=\"1\"/,/KEYMAP=\"${KEYMAP}\"/p" $CMDS

sed -i "s/\/dev\/[ \t]*\/[ \t]*<fff>/\/dev\/${firstdev}     \/            ${FS}/" $CMDS
sed -i "s/\/dev\/     swap         swap/\/dev\/${seconddev}     swap         swap/" $CMDS
sed -n '/# Begin \/etc\/fstab/,/# End \/etc\/fstab/p' $CMDS

sed -i "s/grub-install \/dev\/sda/grub-install \/dev\/${diskdev}/" $CMDS
sed -n "/grub-install \/dev\//p" $CMDS

sed -i "s/root=\/dev\/sda2/root=\/dev\/${firstdev}/" $CMDS
sed -n "/root=\/dev\//p" $CMDS

sed -i "/exec env -i HOME=\$HOME TERM=\$TERM/d" $CMDS
sed -n "/exec env -i HOME=\$HOME TERM=\$TERM/p" $CMDS

sed -i "/. .bashrc/d" $CMDS
sed -i "/cat > ~\/.bash_profile << \"EOF\"/a . .bashrc" $CMDS
sed -n "/cat > ~\/.bash_profile << \"EOF\"/,/cat > ~\/.bashrc << \"EOF\"/p" $CMDS

source ${CMDS}

debug CWD
debug HOME
debug firstdev
debug seconddev
debug diskdev

if ! grep "SettingUptheEnvironment" $SUCCESS ; then

log "Create bashrc for LFS user"

SettingUptheEnvironment


block "$(env)"

echo "SettingUptheEnvironment" >>$SUCCESS
else
log "SettingUptheEnvironment been done! Move on"
fi



cd $sources

#>$SUCCESS
####### Begin chapter 5 building #########
log "Begin to build tools chain"

for pack in $CHAPTER5
do	
	packorder="${pack,,}_chapter5"

	if ! grep "$packorder" $SUCCESS ; then
	packstr=$(echo "${pack,,}" | sed -e 's|^\([a-zA-Z]*-*[a-zA-Z]*\)-.*|\1|gI')
	debug packorder
	debug packstr
	block $packorder
	package=$(find $sources -name ${packstr}*.xz -o -name ${packstr}*.bz2 -o -name ${packstr}*.gz -type f)
	debug	package
	log "Building ${package} of chapter 5"
	debug PWD
	buildfolder=${packstr}"-build"
	[ -d "$buildfolder" ] && { log "Previous ${buildfolder} exists,removing"; rm -rf $buildfolder; }
	prefolder=$(find $sources -maxdepth 1  -name $packstr"*" -type d)
	
	debug prefolder
	
	[ -d "$prefolder" ] && { log "Previous ${prefolder} exists,removing"; rm -rf $prefolder; }

	
	[ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf $package -C $sources --checkpoint=100 --checkpoint-action=dot ; echo "\n"; } 

	newfolder=$(find $sources -maxdepth 1  -name $packstr"*" -type d)

	debug newfolder

	[ -d "$newfolder" ] && { log "Entering ${newfolder}"; cd $newfolder; }

	debug PWD
	func=$(echo $pack | sed -e 's/[(). -]/_/g')
	func=${func}"_chapter5"
	debug func
	time ${func}
	if  ! grep "$func" ${CMDS}  ; then  log func ; fi
	log "${packorder} building Complete! Leaving ${PWD} and back to ${sources}"
	cd ${sources}
	echo $packorder >>$SUCCESS
	else
	log "$packorder been built,skip"
	continue
	fi
	
done

set +e
if ! grep "Stripping" $SUCCESS ; then
log "Stripping....."
Stripping
echo "Stripping" >>$SUCCESS
else
log "Stripping been done! Move on"
fi


if ! grep "PreparingVirtualKernelFileSystems" $SUCCESS ; then
log "Preparing Virtual Kernel FileSystems....."
PreparingVirtualKernelFileSystems
echo "PreparingVirtualKernelFileSystems" >>$SUCCESS
else
log "PreparingVirtualKernelFileSystems been done! Move on"
fi


log "Create ${LFSBUILD} "

mkdir -pv ${LFSBUILD} 
set -e

log "Copy nessary files to ${LFSBUILD}" 

cp -fv ${FUNCTIONS} ${CMDS} "${CWD}/lfschroot.sh" ${LFSBUILD}
chmod -v +x ${LFSBUILD}/lfschroot.sh

log "Entering the Chroot Environment....."

/usr/sbin/chroot "$LFS" /tools/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h -c "/lfsbuild/lfschroot.sh"


if ! grep "StrippingAgain" $SUCCESS ; then
log "Stripping   Again....."

/usr/sbin/chroot $LFS /tools/bin/env -i \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /tools/bin/bash --login -c "cd /lfsbuild;. cmds; StrippingAgain"
echo "StrippingAgain" >>$SUCCESS
else
log " StrippingAgain been done! Move on"
fi




onexit()

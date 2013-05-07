#!/tools/bin/bash
set -e
LFSBUILD=/lfsbuild
MAKEFLAGS='-j 4'
DEBUG_="true"
sources="/sources"
tools="/tools"
script=$(readlink -f "$0")
CWD=$(dirname "$script")
CMDS=${LFSBUILD}/cmds
LANG="en_US.utf8"
SUCCESS=${sources}/"LFSSUCCESS"

source ${LFSBUILD}/functions.sh

source ${CMDS}

cd $sources

for pack in $CHAPTER6
do	
	packorder="${pack,,}_chapter6"

	if ! grep "$packorder" $SUCCESS ; then
	packstr=$(echo "${pack,,}" | sed -e 's|^\([a-zA-Z]*-*[a-zA-Z]*\)-.*|\1|gI')
	case "${packorder}" in
		*systemd* ) packstr="systemd" ;;
	esac
	debug packorder
	debug packstr
	block $packorder
	package=$(find $sources -maxdepth 1 -name ${packstr}*.xz -o -name ${packstr}*.bz2 -o -name ${packstr}*.gz -type f | head -1)
	debug	package
	log "Building ${package} of chapter 6"
	debug PWD
	buildfolder=${packstr}"-build"
	[ -d "$buildfolder" ] && { log "Previous ${buildfolder} exists,removing"; rm -rf $buildfolder; }
	prefolder=$(find $sources -maxdepth 1  -name $packstr"*" -type d | head -1)
	
	debug prefolder
	
	[ -d "$prefolder" ] && { log "Previous ${prefolder} exists,removing"; rm -rf $prefolder; }

	
	[ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf $package -C $sources --checkpoint=100 --checkpoint-action=dot ; echo "\n"; } 

	newfolder=$(find $sources -maxdepth 1  -name $packstr"*" -type d | head -1)

	debug newfolder

	[ -d "$newfolder" ] && { log "Entering ${newfolder}"; cd $newfolder; }

	debug PWD
	func=$(echo $pack | sed -e 's/[(). -]/_/g')
	func=${func}"_chapter6"
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

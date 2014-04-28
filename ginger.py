#!/usr/bin/env python
#1.04 Change dist name
#1.03 change allstr += "$(" + ch.name + ") " to allstr += ch.name
# 1.02

from lfs import Book,Chapter,Page,Package
import time,glob,os

link = "www.linuxfromscratch.org/blfs/view/stable/index.html"

DISTNAME = "ginger"
LFS=""
SOURCES=LFS + '/sources'

blfs = Book(link, Book("www.linuxfromscratch.org/lfs/view/stable/index.html"))


port 		= "/port"
portdir 	=  LFS + port
makefolder 	= portdir + "/makefiles"
scriptfolder	= portdir + "/scripts"
logfolder 	= portdir + "/logs"
replace_delete_log =""
blfs_script_link=""
blfs_script_pkg =""
blfs_script_ver =""
allshortnames	=""
comment	="#This file is automatically generated,shall not be modified \n"
comment += "#Generated at : " +  time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + "\n"
ccounter=0
pcounter=0
wrapper= LFS + "/sbin/" + DISTNAME

buildcmd='''\
#!/bin/bash
makedir=''' + makefolder.replace(LFS,"") + '''
makefile="${makedir}/Makefile"
NORMAL="\e[0m"
RED="\e[1;31m"
GREEN="\e[1;32m"


[ `id -u` = "0" ] || { echo "you are not root!"; exit 1;}

[ $# -ne 1 ] && { echo "Need one package name to initiate installation"; exit 1;}

packname=$1

ret=$(grep --color -oEi "^[^0-9]*${packname}.* :" "$makefile" | sed 's@:@@g')

counter=0
for r in $ret
do
counter=$((counter+1))
pkg[$counter]=$r
echo -e "$GREEN $r $NORMAL ${RED}[${NORMAL}${counter}${RED}]${NORMAL}:"
done
if [ $counter -gt 1 ] ; then
	echo "There are $counter matches found, which you do you want to install ?"

	select yn in ${pkg[@]}; do

		for a in "${pkg[@]}"
		do 
		    case $yn in
		       "$a") cd ${makedir} && make $yn;break;;
		    esac
		done
	    exit
	done
else if [ $counter -eq 1 ] ; then
	
		echo -e "Will install ${RED}${pkg[1]}${NORMAL} ,OK[Y/N]?"
		read -p ": " yn
		case $yn in
		y|Y) cd ${makedir} && make ${pkg[1]};;
		*)   exit ;;
		esac

     else 
		echo "No Match found,quit!"; exit 0
     fi
fi
	
'''
header='''\
PORTDIR=''' + port + '''
D	= -x
SHELL 	= /bin/bash
SOURCES = /sources
LOGDIR	= $(PORTDIR)/logs
SCRIPTDIR = $(PORTDIR)/scripts
REDIRECT= > $(LOGDIR)/$@.log

BOLD    = "\e[0;1m"
RED     = "\e[1;31m"
GREEN   = "\e[0;32m"
ORANGE  = "\e[0;33m"
BLUE    = "\e[1;34m"
WHITE   = "\e[00m"
YELLOW  = "\e[1;33m"

OFF     = "\e[0m"
REVERSE = "\e[7m"

tab_    = '	'
nl_     = ''

define echo_message
  @echo -e $(BOLD)--------------------------------------------------------------------------------
  @echo -e $(BOLD)$(1) Package $(BLUE)$@$(BOLD)$(WHITE)
endef

'''

header = comment + "\n" + header

def rwreplace_delete_log():
	global replace_delete_log
	replacefile= blfs.version.replace(" ","_") + "_replace_delete.log"
	file = open(replacefile,'wb')	
	file.write(replace_delete_log)
	file.close

def create_wrapper():
	if not os.path.exists(LFS + "/sbin"):
		os.makedirs(LFS + "/sbin")
	file = open(wrapper,'wb')
	file.write(buildcmd)
	file.close
	os.chmod(wrapper,0744)

def writescript(name,scriptstr):
	scriptfile= scriptfolder + "/" + name.strip() + ".sh"
	file = open(scriptfile,'wb')
	file.write(scriptstr)
	file.close

def base_init():

	if not os.path.exists(portdir):
		os.makedirs(portdir)

	if not os.path.exists(makefolder):
		os.makedirs(makefolder)	

	if not os.path.exists(scriptfolder):
		os.makedirs(scriptfolder)
	else :
		filelist = glob.glob(scriptfolder + "/*")
		for f in filelist:
			os.remove(f)

	if not os.path.exists(logfolder):
		os.makedirs(logfolder)

def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def main():
	global replace_delete_log
	allstr = "all : "
	chapterstr = ""
	chaptertgt = ""
	
	makestr = ""
	for ch in blfs.chapters:
		print ch.name,'chapertname'
		chapterstr += ch.name + " = "
		#allstr += "$(" + ch.name + ") "
		allstr += ch.name + " "
		chaptertgt += ch.mkblock()
		
		for page in ch.pages:
			
			packs = page.packages
			if packs:
				for pack in packs:
					
					if not containsAny(pack.shortname,['about-devices','notes-on-building-software','conventions-used-in-this-book','locale-related-issues']):
						chapterstr += pack.fullname + " "

						pack.writescript(pack.fullname,scriptfolder)
						if not containsAny(pack.shortname, ['configuring-for-adding-users','about-devices','the-bash-shell-startup-files','the-etc-shells-file','random-number-generation','compressing-man-and-info-pages','lsb']):
							makestr += pack.makeblock("after-lfs-configuration-issues")
						else:
							makestr += pack.makeblock()
						
						
						replace_delete_log += pack.delete_log + pack.replace_log
		
		chapterstr += "\n\n"
		
	allstr += " \n\n"
	mkfile= makefolder + "/Makefile"
	mainfile = open(mkfile,'wb')
	mainfile.write(header)
	mainfile.write(allstr)
	mainfile.write(chapterstr)
	mainfile.write(chaptertgt)
	mainfile.write(makestr)
	mainfile.close

base_init()
main()
rwreplace_delete_log()
create_wrapper()

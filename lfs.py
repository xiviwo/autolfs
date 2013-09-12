#!/bin/env python
#1.01

import urllib2,os,binascii,re,sys,platform,glob,time
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
try:
	from BeautifulSoup import BeautifulSoup
except ImportError:
	from bs4 import BeautifulSoup

scriptheader1='''\
#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
'''

scriptheader2='''\
export MAKEFLAGS='-j 4'
env
preparepack()
{
cd ${SOURCES}
local shortname=$1
local version=$2
local packname=$3
rm -rf ${shortname}-${version} 
rm -rf ${shortname}-build
mkdir -pv ${shortname}-${version}  
case $packname in 
	*.zip)
	unzip -x $packname -d ${shortname}-${version}
	;;
	*)
	tar xf $packname -C ${shortname}-${version} --strip-components 1
	;;
esac
}

nwget()
{
local packlink=$1
wget --no-check-certificate -nc --timeout=60 --tries=5 $packlink -P ${SOURCES}
}
'''
IP="192.168.122.13"
GATEWAY="192.168.122.1"
BROADCAST="192.168.122.255"
domain="ibm.com"
nameserver1 ="192.168.122.1"
nameserver2 ="192.168.122.1"
hostname= "alfs"
guestdev1="vda1"
guestdev2="vda2"
guestfs="ext3"
guestdev="vdb"
newuser = "mao"
passwd = "ping" 
hostdev1="vdb1"
hostdev2="vdb2"
arch=platform.machine()
if arch == 'i686':
	ABI=32
elif arch == 'x86_64':
	ABI=64
else:	
	print "Unknown platform error"
	raise 
replace_log	=""
delete_log 	= ""

globalreplace = [
		('&lt;',						'<'),
		('&gt;',						'>'),
		
		('&amp;',						'&'),
		('&lt;&lt;',						'<<'),
		("IP=192.168.1.1",					"IP="+IP),
		("GATEWAY=192.168.1.2",					"GATEWAY=" + GATEWAY),
		("BROADCAST=192.168.1.255",				"BROADCAST=" + BROADCAST),
		('KEYMAP="de-latin1"',					'KEYMAP="us"'),
		('KEYMAP_CORRECTIONS="euro2"',				''),
		('LEGACY_CHARSET="iso-8859-15"',			''),
		('FONT="LatArCyrHeb-16 -m 8859-15"',			''),
		("chown -v",						"chown -Rv"),
		('DISTRIB_CODENAME="<your name here>"',			'DISTRIB_CODENAME="MAO"'),
		("passwd lfs",						"echo 'lfs:ping' | chpasswd"),
		("passwd root",					"echo 'root:ping' | chpasswd"),
		("make test",						""),
		("exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash",		"source /home/lfs/.bashrc"),
		("set root=(hd0,2)",					"set root=(hd0,1)"),
		("root=/dev/sda2 ro",					"root=/dev/" + guestdev1 + " ro"),
		("./configure --prefix=/usr --enable-cxx",		"ABI=" + str(ABI) +" \n\t./configure --prefix=/usr --enable-cxx"),
		("--with-libpam=no",					""),
		("./configure --sysconfdir=/etc",			"./configure --sysconfdir=/etc --with-libpam=no"),
		("grub-install /dev/sda",				"grub-install /dev/" + guestdev ),
		("useradd -m <newuser>",				'useradd -m ' + newuser),
		("<username>",						newuser),
		("<password>",						passwd),
		('groupadd lfs',					'groupadd lfs || true'),
		('useradd -s /bin/bash -g lfs -m -k /dev/null lfs',	'useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true'),
		('cat > ~/.bash_profile << "EOF"',			'cat > /home/lfs/.bash_profile << "EOF"'),
		('cat > ~/.bashrc << "EOF"',				'cat > /home/lfs/.bashrc << "EOF"'),
		('source ~/.bash_profile',				'source /home/lfs/.bash_profile')
	 
	
		
]
globalregx = [
		(r"domain\s*<Your\s*Domain\s*Name>",				"domain " + domain),
		(r"nameserver\s*<IP\s*address\s*of\s*your\s*primary\s*nameserver>",	"nameserver " + nameserver1),
		(r"nameserver\s*<IP\s*address\s*of\s*your\s*secondary\s*nameserver>",	"nameserver " + nameserver2),
		(r"127\.0\.0\.1\s*<HOSTNAME\.example\.org>\s*<HOSTNAME>\s*localhost","127.0.0.1 localhost\n" + IP + "	alfs"),
		(r'echo\s*"HOSTNAME=\s*<lfs>"\s*>\s*/etc/sysconfig/network',	'echo "HOSTNAME=' + hostname + '" > /etc/sysconfig/network'),
		(r"/dev/\s*<xxx>\s*/\s*<fff>",					'/dev/' + guestdev1 + '     /            ' + guestfs + '    '),
		(r"/dev/\s*<yyy>\s*swap\s*swap",					'/dev/' + guestdev2 + '    swap         swap'),
		(r"export\s*LANG=\s*<ll>_<CC>\.<charmap><@modifiers>",		"export LANG=en_US.utf8"),
		(r"mkdir\s*-v",						"mkdir -pv"),
		(r"mkdir\s*/",							"mkdir -pv /"),
		(r"mount\s*-v\s*-t\s*ext3\s*/dev/\s*<xxx>\s*\$LFS",		'mount -v -t ext3 /dev/' + hostdev1 + ' $LFS'),
		(r"/sbin/swapon\s*\-v\s*/dev/\s*<zzz>",			"/sbin/swapon -v /dev/" + hostdev2),
		(r"make\s*LANG=\s*<host_LANG_value>\s*LC_ALL=\s*menuconfig",	'yes "" | make oldconfig'),
		(r"zoneinfo/\s*<xxx>",						"zoneinfo/Asia/Shanghai"),
		(r"PAGE=\s*<paper_size>",					"PAGE=A4")
]

ignorelist = ['dummy',
	'libfoo',
	'make check',
	'localedef',
	'tzselect',
	'spawn ls',
	'ulimit',
	':options',
	'logout',
	'\nexit',
	'shutdown -r',
	'grub-img.iso',
	'hdparm -I /dev/sda | grep NCQ',
	'video4linux/',
	'make -k check',
	'make -k test',
	'make test',
	'udevadm test',
	'test_summary',
	'83-cdrom-symlinks.rules',
	'cat /etc/udev/rules.d/70-persistent-net.rules',
	'locale -a',
	'locale name',
	'glibc-check-log',
	'su - lfs',
	'bash -e',
	'grep FATAL check.log',
	'<report-name.twr>',
	'readelf',
	'ABI=32 ./configure ...',
	'make NON_ROOT_USERNAME=nobody check-root',
	'su nobody -s /bin/bash ',
         '-c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"',
	'gmp-check-log',
	'mkdir -v $LFS/usr',
	'mount -v -t ext3 /dev/<yyy> $LFS/usr',
	'make RUN_EXPENSIVE_TESTS=yes check',
	'convmv',
	'</path/to/unzipped/files>',
	'lp -o number-up=2 <filename>',
	'gpg --verify ',
	'gpg gpg --keyserver pgp.mit.edu --recv-keys 0xF376813D',
	'cd /tmp &&',
	'exec /tools/bin/bash --login +h',
	'sed -i \'s/if ignore_if; then continue; fi/#&/\' udev-lfs-197-2/init-net-rules.sh',
	' /etc/udev/rules.d/70-persistent-net.rules',
	'chown -Rv nobody .',
	'exec /bin/bash --login +h',
	'/tools/bin/bash --login',
	'unset pathremove pathprepend pathappend',
	'mkdir -pv /etc/pam.d/',
	'patch -Np1 -i ../Python-2.7.3-bsddb_fix-1.patch &&',
	'tar xvf krb5-1.11.2.tar.gz',
	'cd krb5-1.11.2',
	"ABI=" + str(ABI),
	'install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat \\',
	'    /etc/sgml/sgml-docbook.cat',
	'sshfs THINGY:~ ~/MOUNTPATH',
	'fusermount -u ~/MOUNTPATH',
	'tripwire --init',
	"egrep '^flags.*(vmx|svm)' /proc/cpuinfo",
	'export LIBRARY_PATH=/opt/xorg/lib',
	"export MAKEFLAGS='-j 2'",
	"make -j2",
	'bash tests/run.sh',
	'pushd testsuite',
	"sed -i -e 's|exec which sleep|exec echo /tools/bin/sleep|' \\",
	'.exp',
	'popd',
	"sed -i -e 's/\"write_cd_rules\"/\"write_cd_rules 	mode\"/' \\"
	]

packmakeblock='''\
	@$(call echo_message, Building)
	@LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
'''

def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]


def NormName(name):
	namestrip= re.compile("\\b&nbsp;\\b|[ \~\:\+\.\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
	return namestrip.sub("-",name).lower().encode('utf-8').strip("-")

def shortname(name):

	pkgname =  NormName(name)
	namematch = re.search("^([a-zA-Z0-9]+(-[0-9]*[a-zA-Z]+[0-9]*)*)",pkgname)
	shortname = namematch.group(1)
	return shortname

def version(name):
	versionmatch = re.search("-([0-9.]+)",name)

	try:
		version = versionmatch.group(1)
	except AttributeError:
		version = ""
	return version

def grep(pattern,fileObj):
	
	for line in open(fileObj,'r'):
		
		if re.search(pattern,line):
			return line


class Package:
	def __init__(self,no,name,cmds,downs,depends,page,chapter,book):
		self.name = name
		self.no = no
		self.commands = cmds
		self.downloads = downs
		self.dependency = depends
		self.replace_log =""
		self.delete_log ="" 
		self.page = page
		self.chapter = chapter
		self.book = book
		self.targetname = self.no + "-" + self.shortname + " "
		self.fullname = self.shortname + "-" + self.version
	def makeblock(self,extra_depend=""):
		makestr = ""
		packtgt = self.no + "-" + self.shortname + " "
		makestr += "\n\n" + packtgt + " : " + self.dependency + extra_depend + "\n" + packmakeblock
		return makestr

	def script(self):
		scriptstr =""
		short = self.shortname
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		scriptstr += scriptheader1 + "pkgname=" + short + "\nversion=" + self.version + "\n" + scriptheader2
					
		if self.downloads:
			for link in self.downloads:
				
				if "blfs" in self.book.link and 'wget' not in short and 'openssl' not in short:
					print short
					scriptstr += "nwget " + link + "\n"
			scriptstr += "preparepack \"$pkgname\" \"$version\" " + self.parselink(self.downloads[0]) + "\n"
			scriptstr += "cd ${SOURCES}/${pkgname}-${version} \n"
		if self.commands:
			for line in self.commands:
				for lin in self.lineadd(self.findchild(line)):
			
					scriptstr += lin
		if self.downloads:	
			scriptstr += "cd ${SOURCES}\nrm -rf ${pkgname}-${version} \nrm -rf ${pkgname}-build\n"
		return scriptstr

	def parselink(self,download_link):
		packname=""
	
		if download_link:
			packmat = re.search("/([-.\w]*[^/]*\.*(tar)*\.*((zip)|(tar)|(bz2)|(xz)|(gz)|(tgz))+$)",download_link)
		
			try:
				packname = packmat.group(1)
			except AttributeError:
				packname = ""
		return packname

	def findchild(self,tag):
		cmdline=""

		if tag.string!=None:
			tmpstr = tag.string
			cmdline = cmdline + "\n" + tmpstr

		else:
			cmdline = cmdline + "\n"
			for code in tag.contents:
				#L2
				if code.string != None:
					cmdline = cmdline + code.string
				else:
			
					for em in code.contents:
						#L3
						if em.string != None:
							cmdline = cmdline + "\t" +  em.string
					
			cmdline = cmdline + "\n"						
		return cmdline

	def lineadd(self,block):
		
		lst = []
		if block:
			for i,line in enumerate(block.splitlines()):
				if line and line !="\n":
	 
				 	if  containsAny(line,ignorelist):
						self.delete_log += "\n--------------------" + self.name + "-------------------------\n"
						self.delete_log += "Delete line : " + str(i) + " : " + line + " from :\n"
						self.delete_log += block + "\n"
						pass
			   		else:
				
						lst.append(self.massreplaceline(line) + "\n")
		return lst

	def massreplaceline(self,string):
		
		for k, v in OrderedDict(globalreplace).iteritems():

			if k in string:
			
				self.replace_log += "\nOrigin    : " + string + "\n"
				self.replace_log += "Replacing : " + k + " with : " + v  + "\n"
				self.replace_log += "Rules     : " + k + "\n"
				self.replace_log += "-------------------------------------------------\n"
	   			string = string.replace(k, v)
			
	
		for k, v in OrderedDict(globalregx).iteritems():
			laststr = string
	
			string = re.sub(k ,v, laststr)#,flags=re.DEBUG)
			if string != laststr:

				self.replace_log += "\nOrigin    : " + laststr + "\n"
				self.replace_log += "Replacing : " + laststr + " with : " + string  + "\n"
				self.replace_log += "Rules     : " + k + "\n"
				self.replace_log += "-------------------------------------------------\n"
				 
	
		return string

	@property
	def version(self):
		return version(self.name)
	@property
	def shortname(self):
		pkgname =  NormName(self.name)
		namematch = re.search("([a-zA-Z]+[a-zA-Z0-9]*(-[0-9]*[a-zA-Z]+[0-9]*)*)",pkgname)
		shortname = namematch.group(1)
		return shortname


		

class Page:
	def __init__(self,pageNo,pagename,pagelink,chapter,book):
		self.no= pageNo
		self.name = pagename
		self._packages = []
		self.book = book
		self.link = self.book.bookdir + "/" + pagelink
		self.chapter = chapter
		#self.populate()
		#self.pagesoup = self.openpage()
	def show(self):
		print self.no,self.name,self.link
	def openpage(self):
		return BeautifulSoup(open(self.link).read())
	

	def parsedownload(self,subsoup):
		download_link = []
		short = shortname(self.name)
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		if os.path.exists(self.book.wget_list):
			link = grep('/' + shortname(short) + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.wget_list)
			if link:
				download_link.append(link)
		if download_link:
			#print download_link
			return download_link
		else:
			uls=subsoup.findAll("ul",attrs={'class':'compact'})
			counter=0
			if uls:
		
				for ul in uls:
					for alink in ul.findAll("a",attrs={'class':'ulink'}):
				
						if str(alink['href']).endswith('/') or "certdata" in str(alink['href']) or str(alink['href']).endswith('.html') :
							pass  
						else:
							download_link.append(alink['href'])

			return download_link

	def parsedependency(self,depsoup):
	
		ps=depsoup.findAll("p",attrs={'class':re.compile(r"^(recommended|required)$")})
		if ps:
			dependstr_link=""

			for p in ps:
				child_iter = iter(p.contents)
				for child in child_iter:
					
					if  hasattr(child,"name"):
						
						if  hasattr(child,"title"):

								pkgname = NormName(child.text)
					
								if containsAny(pkgname,["x-window-system"]):
									short =  "x-window-system-environment"
								else:
									short = shortname(pkgname)
								ver = version(child.text.lower())	
								if ver:
									dependstr_link += short + "-"  + ver + " "
								else:
 									dependstr_link += short + " "
				
					else:
						orstrip = re.compile("[ \t,\n\r]+",re.MULTILINE)
						orstr = orstrip.sub("",child.string)
						if orstr=="or":
							next(child_iter,None)
							continue
					
		else:
			dependstr_link=""

		return dependstr_link
	def addpack(self,package):
		self._packages.append(package)

	@property
	def packages(self):
		print "lazy generating packages :" + shortname(self.name)
		if not self._packages:
			pagesoup = self.openpage()
			string = shortname(self.name)
			
			if string in "python-modules" or string in "xorg-drivers" :
				headers = pagesoup.findAll('h2',attrs={'class':'sect2'})
			else:
				headers = pagesoup.findAll('h1',attrs={'class':'sect1'})
			plist = [] 
			for i,header in enumerate(headers):
			 
				
				cmds=header.parent.findAll("kbd",{'class':'command'})
				if cmds:
					packname = header.text
					packno = str(self.no) + str(i+1)
					downs =  self.parsedownload(header.parent)
					depends = self.parsedependency(header.parent)
					plist.append(Package(packno,packname,cmds,downs,depends,self,self.chapter,self.book))
			self._packages = plist
		return self._packages
						

class Chapter:
	def __init__(self,no,name,section,book):
		self.no = no
		self.name = self.normname(name)
		self.book = book
		self.soup = section
		self._pages = []
		#self.populate()	

	def listpage(self,pagesection,tag):
		if not self._pages:
			plist = []
			pagesgrp = pagesection.findNextSiblings()
			for pageul in pagesgrp:
				pages = pageul.findAll(tag)
				for i,p in enumerate(pages):
					 
					plist.append(Page(str(self.no) + str(i+1).zfill(2),p.text,p['href'],self,self.book))
			self._pages = plist

	def addpage(self,page):
		self._pages.append(page)


	def normname(self,name):
		namestrip= re.compile("\\b&nbsp;\\b|[ 0-9\~\:\+\.\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
		return namestrip.sub("-",name).lower().strip("-")

	@property
	def pages(self):
		print "lazy generating chapters for:" + self.name
		self.listpage(self.soup,"a")
		return self._pages

	
	
class Book:

	def __init__(self,name,link):
		self._chapters= []
		self.name = name
		self.link = link
		self.version = self.bookversion()
		self.bookdir = os.path.dirname(self.link)
		self.wget_list = self.bookdir + "/wget-list"
		self.version = self.version
		#self.populate()
	def openbook(self):
		if not os.path.exists(self.link):
			os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent " + self.link)
		return BeautifulSoup(open(self.link).read())
	
	def listchapter(self,booksoup,tag):
		if not self._chapters:
			clist = []
			chapters =  booksoup.findAll(tag)
			for i,ch in enumerate(chapters):
				tmpch = Chapter(i,ch.text,ch,self)
				clist.append(tmpch)
			self._chapters = clist
		 
	def addchapter(self,chapter):
		self._chapters.append(chapter)

	def bookversion(self):
		version=self.openbook().findAll("h2",attrs={'class':"subtitle"})
		if version:
			for v in version:
				return v.text
	def package(self,name):
		for ch in self.chapters:
			for page in ch.pages:
				if page.packages:
					for pack in page.packages:
						if name.lower() in pack.shortname:
							return pack
		return None

	@property
	def chapters(self):
		print "lazy generating chapters for :",self.name
		self.listchapter(self.openbook(),"h4")
		return self._chapters

'''
def blfstest():
	#
	link = "www.linuxfromscratch.org/blfs/view/svn/index.html"
	lfs = Book("LFS",link)
	page = lfs.chapters[13].pages[24]
	#page.populate()
	for pack in page.packages:
		print pack.no
	 	print pack.name
		print pack.shortname,"-",pack.version
		print pack.commands
		print pack.downloads
		print pack.dependency
		print "------------------------"
	

def lfstest():
	link = "www.linuxfromscratch.org/lfs/view/stable/index.html"
	lfs = Book("LFS",link)
	page = lfs.chapters[5].pages[6]
	#page.populate()
	for pack in page.packages:
		print pack.no
	 	print pack.name
		print pack.shortname,"-",pack.version
		print pack.commands
		print pack.downloads
		print pack.dependency
		print "------------------------"
	
	
	for ch in lfs.chapters:
		print ch.name,ch.no
		 
		for page in ch.pages:
			if page.packages:
				for package in page.packages:
					#print dir(page.packages)
					#package = page.packages
					print "	",package.no	
					print "	",package.name
					print "      ",package.downloads
					print "      ",package.dependency
					print "      --------------------------------"
'''
#blfstest()
#lfstest()

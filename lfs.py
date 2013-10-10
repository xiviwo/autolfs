#!/bin/env python
#1.06

import urllib2,os,binascii,re,sys,platform,glob,time
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
try:
	from BeautifulSoup import BeautifulSoup,SoupStrainer
except ImportError:
	from bs4 import BeautifulSoup,SoupStrainer
from collections import deque

scriptheader1='''\
#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
'''

scriptheader2='''\
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
LFSHOME = "/home/lfs"

arch=platform.machine()
if arch == 'i686':
	ABI=32
elif arch == 'x86_64':
	ABI=64
else:	
	print "Unknown platform error"
	raise 

perl_pack_lists= "perl_pack_lists"

counter = 0
lfsreplace = [
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
		('groupadd lfs',					'groupadd lfs || true'),
		('useradd -s /bin/bash -g lfs -m -k /dev/null lfs',	'useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true'),
		('cat > ~/.bash_profile << "EOF"',			'cat > ' + LFSHOME + '/.bash_profile << "EOF"'),
		('cat > ~/.bashrc << "EOF"',				'cat > ' + LFSHOME + '/.bashrc << "EOF"'),
		('source ~/.bash_profile',				'source ' + LFSHOME + '/.bash_profile'),
							
]

blfsreplace = [
		('&lt;',						'<'),
		('&gt;',						'>'),
		
		('&amp;',						'&'),
		('&lt;&lt;',						'<<'),
		("<newuser>",						newuser + " || true"),
		("<username>",						newuser),
		("<password>",						passwd),
		("ln -s ",						"ln -svf "),
		("<new-password>",					passwd)					
]

lfsregx = [
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

blfsregx = [
		(r"mkdir\s*-v",						"mkdir -pv"),
		(r"mkdir\s*/",							"mkdir -pv /"),
		(r"mkdir\s*",							"mkdir -pv "),
		(r"export\s*LANG=\s*<ll>\s*_\s*<CC>\s*\.\s*<charmap>\s*<@modifiers>",		"export LANG=en_US.utf8"),
		(r'"\s*<PREFIX>\s*"',						'"/opt"'),
		(r"\s*</path/to/unzipped/files>\s*",				'')
		#(r"udev-lfs(-([0-9.]+))+",					Book._udev_version)
		
]



lfsignorelist = ['dummy',
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
	'grep FATAL check.log',
	'readelf',
	'ABI=32 ./configure ...',
	'make NON_ROOT_USERNAME=nobody check-root',
	'su nobody -s /bin/bash ',
         '-c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"',
	'gmp-check-log',
	'mkdir -v $LFS/usr',
	'mount -v -t ext3 /dev/<yyy> $LFS/usr',
	'make RUN_EXPENSIVE_TESTS=yes check',
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
	"write_cd_rules"
	]

blfsignorelist = [
	'make -k check',
	'make -k test',
	'make test',
	'bash -e',
	'<report-name.twr>',
	'convmv',
	'</path/to/unzipped/files>',
	'lp -o number-up=2 <filename>',
	'gpg --verify ',
	'gpg gpg --keyserver pgp.mit.edu --recv-keys 0xF376813D',
	'glxinfo'
	]




perlcmd= BeautifulSoup('<kbd class="command">perl Makefile.PL && make && make install</kbd>')

def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]


def NormName(name):
	namestrip= re.compile("\\b&nbsp;\\b|[ \~\:\+\.\-\_\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
	return namestrip.sub("-",name).lower().strip("-")

def shortname(name):

	pkgname =  NormName(name)
	namematch = re.search("([a-zA-Z]+[a-zA-Z0-9]*(-[^.\d][0-9]*[a-zA-Z]+[0-9]*)*)",pkgname)
	#"^([a-zA-Z0-9]+(-[0-9]*[a-zA-Z]+[0-9]*)*)"		
	shortname = namematch.group(1)
	return shortname

def version(name):
	versionmatch = re.search("-([a-zA-Z0-9]*[0-9.]+[a-zA-Z0-9]*)",name.strip(),re.MULTILINE)

	try:
		version = versionmatch.group(1)
	except AttributeError:
		version = ""
	return version

def fullname(name):
	ver = version(name)
	if ver:
		return shortname(name) + "-" + version(name)
	else:
		return shortname(name)



def parselink(download_link):
	packname=""

	if download_link:
		packmat = re.search("/([-.\w]*[^/]*\.*(tar)*\.*((zip)|(tar)|(bz2)|(xz)|(gz)|(tgz)|(pm))+$)",download_link)
	
		try:
			packname = packmat.group(1)
		except AttributeError:
			packname = ""
	return packname

def grep(pattern,files):

		for line in files:
		
			if re.search(pattern,line,re.IGNORECASE):
				
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
		self._version =""
		self._shortname =""
		self._fullname = ""
		self.targetname = self.no + "-" + self.shortname + " "

	def makeblock(self,extra_depend=""):
		makestr = ""
		if "blfs" in self.book.link :
			print self.book.link
			packtgt = self.fullname + " "
			packmakeblock='''\
	@$(call echo_message, Building)
	@source /etc/profile && time $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
'''
		else:
			packtgt = self.targetname + " "
			packmakeblock='''\
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
'''

		makestr += "\n\n" + packtgt + " : " + extra_depend + " " + self.dependency  + "\n" + packmakeblock
		return makestr.encode("utf-8")
	
	def writescript(self,filename,scriptfolder):
		if not os.path.exists(scriptfolder):
			os.makedirs(scriptfolder)
		else:
			scriptfile= scriptfolder + "/" + filename.strip() + ".sh"
			file = open(scriptfile,'wb')
			file.write(self.script())
			file.close
	
	def script(self):
		scriptstr =""
		short = self.shortname
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if containsAny(short,['nss','json','pulseaudio','libiodbc']):
			scriptstr += scriptheader1 + "pkgname=" + short + "\nversion=" + self.version + "\nexport MAKEFLAGS='-j 1'\n" + scriptheader2
		else:
			scriptstr += scriptheader1 + "pkgname=" + short + "\nversion=" + self.version + "\nexport MAKEFLAGS='-j 4'\n" + scriptheader2
		#print '--------',self.version			
		if self.downloads:
			for link in self.downloads:
				
				if "blfs" in self.book.link and 'wget' not in short and 'openssl' not in short:
					
					scriptstr += "nwget " + link + "\n"
				else:
					pass
			scriptstr += "preparepack \"$pkgname\" \"$version\" " + parselink(self.downloads[0]) + "\n"
			scriptstr += "cd ${SOURCES}/${pkgname}-${version} \n"
		if self.commands:
			for line in self.commands:
				
				if type(line) is not str:
					go = 1
					for p in line.parent.findPreviousSiblings():
						if p.findAll('a',{"title" : "BLFS Boot Scripts"}):
							go = 0
							break
					#print "go===========",go
					if go and line.parent.findPreviousSibling():
						prev = line.parent.findPreviousSibling().text.encode('utf-8').strip()
						if containsAny(prev, ['doxygen','Doxygen','texlive','TeX Live','Sphinx']) and not containsAny(prev,['Install Doxygen']):

							pass
						elif   containsAny(prev, ['documentation','manual']) and containsAny(prev, ['If you','API','alternate''optional','Sphinx','DocBook-utils','Additional','PDF','Postscript']) and  not containsAny(prev,['If you downloaded','Man and info reader programs','The Info documentation system']):
							pass
						else:
							
							#
							
							for lin in self.lineadd(self.findchild(line)):
							
								scriptstr += lin
					elif go:
						for lin in self.lineadd(self.findchild(line)):
								
							scriptstr += lin
				else:
					scriptstr += self.massreplaceline(line)

		if self.downloads:	
			scriptstr += "cd ${SOURCES}\nrm -rf ${pkgname}-${version} \nrm -rf ${pkgname}-build\n"
		return scriptstr



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
	 				if "blfs" in self.book.link :
						ignorelist = blfsignorelist
					else:
						ignorelist = lfsignorelist

				 	if  containsAny(line,ignorelist):
						self.delete_log += "\n--------------------" + self.name + "-------------------------\n"
						self.delete_log += "Delete line : " + str(i) + " : " + line + " from :\n"
						self.delete_log += block + "\n"
						pass
			   		else:
				
						lst.append(self.massreplaceline(line) + "\n")
		
		return lst
	
	def massreplaceline(self,string):
 		if "blfs" in self.book.link :
			globalreplace = blfsreplace
			globalregx = blfsregx
		else:
			globalreplace = lfsreplace
			globalregx = lfsregx

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
	def fullname(self):
		if not self._fullname:
		
			if self.version:
				self._fullname = self.shortname + "-" + self.version
			else:
				self._fullname = self.shortname
		return self._fullname

	@property
	def version(self):
		if not self._version :
			self._version = version(self.name)
		return self._version

	@property
	def shortname(self):
		if not self._shortname:
			#pkgname =  NormName(self.name)
					     
			#namematch = re.search("([a-zA-Z]+[a-zA-Z0-9]*(-[0-9]*[a-zA-Z]+[0-9]*)*)",pkgname)
			#shortname = namematch.group(1)
			self._shortname = shortname(self.name)
		return self._shortname


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
		self._soup = None

	def show(self):
		print self.no,self.name,self.link


	
	def parsedownload(self,subsoup):
		download_link = []
		short = shortname(self.name)
		
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if self.book.wget_file_list:

			link = grep('/' + shortname(short) + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.wget_file_list)
			
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

		#strainer = SoupStrainer("p",attrs={'class':re.compile(r"^(recommended|required)$")})
		ps=depsoup.findAll("p",attrs={'class':re.compile(r"^(recommended|required)$")})
		if ps:
			dependstr_link=""

			for p in ps:
				child_iter = iter(p.contents)
				for child in child_iter:
					
					if  hasattr(child,"name"):
						
						if  child.has_key("title"):

								pkgname = NormName(child.text)
					
								if containsAny(pkgname,["x-window-system"]):
									short =  "x-window-system-environment"
								elif containsAny(pkgname,['udev-installed-lfs-version']):
									short = 'udev-extras-from-systemd'
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
	
	def parseexternal(self,link):

		
		shortname = re.search(r'/([^/]*)/$',link,re.IGNORECASE).group(1) #like LWP-Protocol-https
		packlink=""
		if self.book.perl_packs:
			packlink = grep('/' + shortname + '-([0-9.]+)[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.perl_packs)
			
		if packlink:
			return packlink
		else:
			soup = BeautifulSoup(urllib2.urlopen(link).read())
	
			alink = soup.findAll("a",attrs={'href':re.compile("tar\.gz")}) # package link
	
			if alink:
				match = re.search('(http://[^/]+/)',link) #http://search.cpan.org/
				download_link=" " +match.group(1) +  alink[0]['href'].strip("/") + "\n"
				file = open(perl_pack_lists,"a")
				file.write(download_link)
				file.close
				return download_link
			else:
				return ""

	
	def parseperldownload(self,alink):
	
		if alink and alink.has_key('href'):
		
			if str(alink['href']).endswith('/'): #parse external link :http://search.cpan.org/~gaas/LWP-Protocol-https/
			
				return str(self.parseexternal(str(alink['href'])))
				#return alink['href']

			elif   ".html" in str(alink['href']):# same page no need to parse,ex:# /www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
							      #within BLFS, no need to parse
				pass

			else:                               # otherwises, need to parse all 

				return alink['href']
	
	def parseperl(self,plist,i):
		global counter
		#link =  "www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html"
		link = self.book.perl_modules_link
		
		soup = BeautifulSoup(open(link).read())

		titles=soup.findAll('h3')
		pkglist=[]
		perlstr=""
		for title in titles:

			if title != None:
				div = title.findNextSibling(attrs={'class':'itemizedlist'})

				if div != None :
					#func == "Crypt_SSLeay_0_64" :
					self.perldepend(div,"",plist,i,[])
					i = counter
	

	
	def perldepend(self,div,link,plist,i,lastdown):
		global counter
		nextdown = deque()
		if div.string == None:
			for ul in div.contents:
				 if ul.string == None:
					dependency=""			
					downloads=[]					
					for li in ul.contents:   # Iterate over lis
						if li.string == None:
							try:
								url = str(li.a['href'])
							except (KeyError,AttributeError):
								li.a = li.a.findNextSibling(attrs={'class':'ulink'})
								url = str(li.a['href'])
							
							if link and ".html" in url: # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
										     # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/postlfs/openssl.html
								downloads = []
								
							else:        #http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz/ TITLE
								downloads = [ self.parseperldownload(li.a) ]
							
							if downloads:
								packname = parselink(downloads[0]).strip(".tar.gz")
								dependency += fullname(packname) + "  "
							else:
								dependency += fullname(li.a.text) + " "
							
						
							if downloads and not li.div:
								packname = fullname(packname)
								i += 1
								packno = packno = str(self.no) + str(i)
								plist.append(Package(packno,packname,perlcmd,downloads,"",self,self.chapter,self.book))
								counter =  i
							elif downloads:
								for down in downloads:
									nextdown.append(down)
							
					if link:
					
						thisdown = lastdown.popleft() 
						packname = fullname(parselink(thisdown).strip(".tar.gz"))
						
						i += 1
						packno = packno = str(self.no) + str(i)
						plist.append(Package(packno,packname,perlcmd,[thisdown],dependency,self,self.chapter,self.book))
						counter = i

					for li in ul.contents:  # Iterate over div of class itemizedlist
						if li.string == None and li.div:
							# Tiltle of next div need to be iterate, for example, Crypt::SSLeay-0.64
							self.perldepend(li.div,li.div.findPreviousSibling().a,plist,i,nextdown)

	
	@property
	def pagesoup(self):
		if not self._soup:
			self._soup =  BeautifulSoup(open(self.link).read())
		return self._soup

	@property
	
	def packages(self):
		
		print "lazy generating packages :" + shortname(self.name)
		if not self._packages:
			
			pagesoup = self.pagesoup
			string = shortname(self.name)
			
			if string == "python-modules" or string == "xorg-drivers" :
				headers = pagesoup.findAll('h2',attrs={'class':'sect2'})
			else:
				headers = pagesoup.findAll('h1',attrs={'class':'sect1'})
			plist = [] 
			for i,header in enumerate(headers):
			 
				
				cmds=header.parent.findAll("kbd",{'class':'command'})
				if cmds:
					
					packname = header.text
					if string == "libvpx":
						packname = string + '-' + version(self.name).replace('v','')

					if string == 'xkeyboardconfig':
						packname = 'xkeyboard-config' + "-" + version(self.name)
					if string == "perl-modules":
						
						self.parseperl(plist,i)
						i = counter
					else:
						packno = str(self.no) + str(i+1)
						downs = []
						depends = ""
						downs =  self.parsedownload(header.parent)
						if "blfs" in self.book.link:
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
		namestrip= re.compile("\\b&nbsp;\\b|[ 0-9\~\:\+\.\_\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
		return namestrip.sub("-",name).lower().strip("-")
	def mkblock(self):
		mkstr = "" 
		if containsAny(self.name,['the-kde-core','kde-additional-packages']):
			mkstr += "\n\n" + self.name + " : after-lfs-configuration-issues kde-pre-installation-configuration"
			
		elif self.name not in "after-lfs-configuration-issues":
			mkstr += "\n\n" + self.name + " : after-lfs-configuration-issues "
		else:
			mkstr += "\n\n" + self.name + " : "
		mkstr += '''
\t@$(call echo_message, Building)
\t@time source /etc/profile  && make  mk-''' + self.name + '''
\t@touch $@
mk-''' + self.name + " :  $(" + self.name + ")\n\n"
		return mkstr
	@property
	
	def pages(self):
		if not self._pages:
			print "lazy generating chapters for:" + self.name
			self.listpage(self.soup,"a")
		return self._pages

	
	
class Book:
	#_udev_version = ""
	def __init__(self,link,baseonbook=None):
		self._chapters= []
		self._name = ''
		self.link = link
		self._version = ""
		self.bookdir = os.path.dirname(self.link)
		
		self._wget_file_list = []
		self._perl_packs = []
		self._soup = None
		self._perl_modules_link = ""
		
		self._udev_version = ""
		
		if baseonbook and isinstance(baseonbook,Book):
			self.LFS = baseonbook
		else:
			self.LFS = self

		self.wgetlist = self.LFS.bookdir + "/wget-list"
                if self.name == "BLFS":
                       blfsregx.append([r"udev-lfs(-([0-9]+))+",self.udev_version])

		#self.populate()
		
	@property
	def name(self):
		if not self._name :
			if 'blfs' in self.link:
				self._name = "BLFS"
			else:
				self._name = "LFS"
		return self._name

	@property
	def udev_version(self):
		
		if not self._udev_version :
			if self.name != "BLFS" :
				boot = self
				
			else:
				book = self.LFS
				
			pack = book.search("systemd")
			if pack:
				for cmd in pack.commands:
					match = re.search('/(udev-lfs(-([0-9.]+))+)[^/]*\.tar\.((bz2)|(xz)|(gz))$',cmd.text,re.IGNORECASE)
					if match:
						self._udev_version = match.group(1)
		return self._udev_version

	@property
	def wget_file_list(self):
		if not self._wget_file_list and os.path.exists(self.wgetlist):
			for i in open(self.wgetlist,"r"):
				self._wget_file_list.append(i)
		return self._wget_file_list
	@property
	def perl_packs(self):
		if not self._perl_packs and os.path.exists(perl_pack_lists):
			
			for i in open(perl_pack_lists,"r"):
				self._perl_packs.append(i)
		return self._perl_packs
	@property
	def perl_modules_link(self):
		if not self._perl_modules_link :
			
			soup = self.booksoup.findAll(text = re.compile("Perl\s*Modules",re.IGNORECASE))
			for s in soup:
				link = s.parent
			self._perl_modules_link = self.bookdir + "/" + link['href']
		return self._perl_modules_link

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

	def search(self,name):
		
		soup = self.booksoup.findAll(text = re.compile(name,re.IGNORECASE))
		
		chno = 0
		counter = 0
		if soup:
			for a in soup:
				chapters = a.parent.parent.parent.findPreviousSiblings()
			for chapter in chapters:
				chno =  int(re.search("^\s*([0-9]{1,2}).",chapter.text,re.MULTILINE).group(1))
			
			for i,page in enumerate(self.chapters[chno].pages):

				if re.search(name.lower(),page.name.lower(),re.MULTILINE):
					
					counter =  i
					break
		if chno >= 0 and counter >0 :
			return self.chapters[chno].pages[counter].packages[0]
		else:
			return None
	@property
	def version(self):
		if not self._version:
			version=self.booksoup.findAll("h2",attrs={'class':"subtitle"})
			if version:
				for v in version:
					self._version = v.text.strip()	
		return self._version

	@property
	def booksoup(self):
		if not self._soup:
			try:
				self._soup = BeautifulSoup(open(self.link).read())
			except IOError:
				os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent " + self.link)
				self._soup = BeautifulSoup(open(self.link).read())
		
		return self._soup

	@property
	
	def chapters(self):
		if not self._chapters:
			print "lazy generating chapters for :",self.name
			self.listchapter(self.booksoup,"h4")
		return self._chapters



def blfstest():
	#
	
	link = "www.linuxfromscratch.org/blfs/view/svn/index.html"
	blfs = Book(link, Book("www.linuxfromscratch.org/lfs/view/stable/index.html"))
	
	print blfs.udev_version
	#print "-----------",grep('/XML-SAX-Expat-([0-9.]+)[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,lfs.perl_packs)
	#pack = lfs.search("Perl\s*Modules")
	#page = lfs.chapters[13].pages[19]
	#lfs.search("Changing\s*Ownership")
	pack = blfs.search("systemd")
	#print '---------------------',page
	#page.populate()
	#print lfs.perl_modules_link
	#for pack in page.packages:
	if pack:
		print pack.name
		print pack.shortname
	 	print pack.version
		print pack.downloads
		#print pack.script()
		
	#print "downn=",pack.downloads
'''	#print "depend=",pack.dependency
	print "------------------------"

		page = lfs.search('wget')
	if page:
		print page.name,page.dependency
'''
def lfstest():
	link = "www.linuxfromscratch.org/lfs/view/stable/index.html"
	lfs = Book(link)
	
	#pack = lfs.search("Perl\s*Modules")
	#pack = lfs.search("systemd")
	pack = ''
	if pack:
		print pack.name
		print pack.shortname
	 	print pack.version
		print pack.commands
		#print pack.script()
		#for cmd in pack.commands:
		#	match = re.search('/(udev-lfs(-([0-9.]+))+)[^/]*\.tar\.((bz2)|(xz)|(gz))$',cmd.text,re.IGNORECASE)
		#	if match:
		#		print match.group(1)
'''
	for i in lfs.wget_file_list:
		print i
	page = lfs.chapters[5].pages[6]
	for pack in page.packages:
		print pack.downloads


	changeownership = lfs.search("Changing\s*Ownership")
	virtualfs = lfs.search("Preparing\s*Virtual\s*Kernel\s*File\s*Systems")
	print changeownership.no,changeownership.targetname
	print virtualfs.no,virtualfs.name,virtualfs.targetname


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
import cProfile
cProfile.run('blfstest()',"testout",4)
import pstats
p = pstats.Stats('testout')
p.strip_dirs().sort_stats('cumulative').print_stats()
'''

#blfstest()
#lfstest()

#!/usr/bin/env python
#1.10 mass regex applied
#1.09 migrate beautifulsoup to lxml
#1.08 add generate-specs function
#1.07 replace "make oldconfig" with "make localmodconfig"

import urllib2,os,binascii,re,sys,platform,glob,time
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
from collections import deque
from os import error, listdir
from os.path import join, isdir, islink
#import lxml.html.soupparser as soupparser  
from lxml import etree

functionfile = "functions.sh"

scriptheader1='''\
#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/''' + functionfile + "\n"

functionstr='''\
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
CWD=os.path.dirname(os.path.realpath(__file__))

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
("passwd root",						"echo 'root:ping' | chpasswd"),
("make test",						""),
("exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash",		"source /home/lfs/.bashrc"),
("set root=(hd0,2)",					"set root=(hd0,1)"),
("root=/dev/sda2 ro",					"root=/dev/" + guestdev1 + " ro"),
("./configure --prefix=/usr --enable-cxx",		"ABI=" + str(ABI) +" \n\t./configure --prefix=/usr --enable-cxx"),
("--with-libpam=no",					""),
("./configure --sysconfdir=/etc",			"./configure --sysconfdir=/etc --with-libpam=no --with-attr=no --with-selinux=no --with-audit=no --with-acl=no"),
("grub-install /dev/sda",				"grub-install /dev/" + guestdev ),
('groupadd lfs',					'	groupadd lfs || true'),
('useradd -s /bin/bash -g lfs -m -k /dev/null lfs',	'useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true'),
('cat > ~/.bash_profile << "EOF"',			'cat > ' + LFSHOME + '/.bash_profile << "EOF"'),
('cat > ~/.bashrc << "EOF"',				'cat > ' + LFSHOME + '/.bashrc << "EOF"'),
('source ~/.bash_profile',				'source ' + LFSHOME + '/.bash_profile'),
('--enable-no-install-program=kill,uptime',		' --enable-no-install-program=kill,uptime   --disable-acl --without-selinux --disable-xattr'),
('--libexecdir=/usr/lib/glibc',				'--libexecdir=/usr/lib/glibc   --with-selinux=no --with-audit=no'),

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

(r"domain.*Domain.*",					"domain " + domain),
(r"nameserver.*primary.*",				"nameserver " + nameserver1),
(r"nameserver.*secondary.*",				"nameserver " + nameserver2),
(r"127\.0\.0\.1.*HOSTNAME.*",				"127.0.0.1 localhost\n" + IP + "	alfs"),
(r'echo\s*"HOSTNAME.*',					'echo "HOSTNAME=' + hostname + '" > /etc/sysconfig/network'),
(r"/dev/\s*<xxx>\s*/\s*<fff>",				'/dev/' + guestdev1 + '     /            ' + guestfs + '    '),
(r"/dev/\s*<yyy>\s*swap\s*swap",			'/dev/' + guestdev2 + '    swap         swap'),
(r"export\s*LANG=.*",					"export LANG=en_US.utf8"),
(r"mkdir\s*-v",					"mkdir -pv"),
(r"mkdir\s*/",						"mkdir -pv /"),
(r"mount.*\$LFS",					'mount -v -t ext3 /dev/' + hostdev1 + ' $LFS'),
(r"/sbin/swapon\s*\-v\s*/dev/\s*<zzz>",		"/sbin/swapon -v /dev/" + hostdev2),
(r"make\s*LANG=.*menuconfig",				'make localmodconfig'),
(r"zoneinfo/\s*<xxx>",					"zoneinfo/Asia/Shanghai"),
(r"PAGE=\s*<paper_size>",				"PAGE=A4")

]


blfsregx = [

(r"mkdir\s*-v",						"mkdir -pv"),
(r"mkdir\s*/",							"mkdir -pv /"),
(r"mkdir\s*",							"mkdir -pv "),
(r"export\s*LANG=.*",						"export LANG=en_US.utf8"),
(r'"\s*<PREFIX>\s*"',						'"/opt"'),
(r"\s*</path/to/unzipped/files>\s*",				''),
(r'&&$',							''),
#(r"udev-lfs(-([0-9.]+))+",					Book._udev_version)
		
]



lfsignorelist = [
'dummy',
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
'glxinfo',
'mkinitramfs [KERNEL VERSION]'
]

SpecsSkipList = [
'preparing-virtual',
'adjusting',
'cleaning-up',
'entering',
'package-management',
'rebooting',
'stripping',
'conventions-used-in-this-book',
'notes-on-building-software',
'about-devices',
'about-raid'

]


perlcmd= ['perl Makefile.PL && make && make install\n']



def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]


def NormName(name):
	namestrip= re.compile("[\x90-\xff]|\\b&nbsp;\\b|[\s\~\:\+\-\_\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
	return namestrip.sub("-",name).lower().strip("-")

def shortname(name):

	pkgname =  NormName(name)
	namematch = re.search("([a-zA-Z]+[a-zA-Z0-9]*(?:-[^-.\d]*[0-9]*[a-zA-Z]+[0-9]*)*)(?![.\d]+)",pkgname)
	#"^([a-zA-Z0-9]+(-[0-9]*[a-zA-Z]+[0-9]*)*)"	
	#"([a-zA-Z]+[a-zA-Z0-9]*(-[^.\d][0-9]*[a-zA-Z]+[0-9]*)*)"
	#print version(name)
	shortname = namematch.group(1)
	return shortname

def version(name):
	versionmatch = re.search("-([\w]*[0-9.]*[\w]*$)",name.strip(),re.MULTILINE)
	#blfs-bootscripts-20130908.tar.bz2
	#-([a-zA-Z0-9]*[0-9.]+[a-zA-Z0-9]*)
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
def foldername(str):
	if os.path.isdir(str):
		return str
	else:
		 return os.path.dirname(str)

def findfolder(line):
	folders = []
	foldermat = re.findall('[ ](/[^ {},]*)',line)
	if foldermat:
		for fr in foldermat:
			
			folders.append(foldername(fr.strip()))
	
	return folders

def walk2(path,top="/",deeplevel=0): 

	try:
		names = listdir(top)
	except error, err:
		if onerror is not None:
		    	onerror(err)
		return

	for name in names:
		pathtrace = join(top, name)
		if pathtrace in path and isdir(pathtrace):
			top = pathtrace
			deeplevel = walk2(path,top,deeplevel+1)
	return deeplevel

def run_once(f):
	def wrapper(*args, **kwargs):
		if not wrapper.has_run:
			wrapper.has_run = True
			return f(*args, **kwargs)
	wrapper.has_run = False
	return wrapper




def matchgroupuser(lines,line,pre):

	if re.search('groupadd|usermod|useradd',line):
			line = line.strip().strip("&&")
			
			if re.search('useradd',line) and line.endswith('\\'):
				
				pre.append(line)
				pre.append(next(lines))
				return 1
				 
			else:
				pre.append(line + "\n")
				return 1
	else:
		
		return 0

def matchBlock(start,end,lines,line,lst,cont=True,repl=True):
	if re.search(start,line,re.MULTILINE):
		if repl : line =  InstallRegx(InstallSpaceFolder,SpaceFolder).sub(line)
	 	lst.append(line)
		try:
		    while True:
			nline = lines.next()
			
			lst.append(nline)
			if  re.search(end,nline,re.MULTILINE):
				
				return cont
		except StopIteration:
			return cont
	else:
		return False	
	
class MultiRegex(object):
    flags = re.MULTILINE
    

    def __init__(self,exregx,make_func):
        '''
        compile a disjunction of regexes, in order
        '''
	self.regexes = ()
	try:
	
		if type(exregx[0]) is str:
			regx = "(?P<" + make_func.__name__ + str(0) + '>(' + '|'.join(l for l in exregx) + '))'
		else:
			regx = '|'.join("(?P<" + make_func.__name__ + str(i) + '>' + l + ")" for i,l in enumerate(zip(*exregx)[0]))
	
	except IndexError:
		raise Exception('Regex {0} list is Null'.format(exregx))

	ex = "|" + regx if self.regexes  else regx
	#print 'ex=======',"|".join(self.regexes) +  ex
        self._regex = re.compile("|".join(self.regexes) +  ex , self.flags)

	#print self._regex.pattern

	if type(exregx[0]) is str:
	        name = make_func.__name__ + str(0)

	        if callable(make_func):
		    #_method = make_func(name)
		  
		    setattr(self, name, make_func)
	else:
		
		for i,v in enumerate(exregx):
		    
		    name = make_func.__name__ + str(i)
		    print 'create function: ',name,i,v
		    if callable(make_func):
			    _method = make_func(i,exregx)
			  
			    setattr(self, name, _method)
		 

    def search(self,s,*args):
	c = 0
	for mo in self._regex.finditer(s):
		print 'search===',mo.groupdict()
		for k,v in mo.groupdict().iteritems():

		    if v:
		        func = getattr(self, k)
			
		
		        if callable(func):
		            func(self,mo,*args)
			    break
			else:
				
		            func
			    break
		c += 1
	return c > 0 

    def sub(self,s,*args):
        return self._regex.sub(self._sub, s)

    def _sub(self, mo,*args):
        '''
        determine which partial regex matched, and
        dispatch on self accordingly.
        '''
	print 'sub===',mo.groupdict()
        for k,v in mo.groupdict().iteritems():
	    
            if v:
                sub = getattr(self, k)
                if callable(sub):
                    return sub(self,mo,*args)
                return sub
        raise AttributeError,'nothing captured, matching sub-regex could not be identified'




BuildSubRegex = (
(r'patch -Np1 -i ../',		'patch -Np1 -i %_sourcedir/'),
(r'f ../',			"f  %_sourcedir/"),

)

BuildCDRegex =(
r'cd .*',
)

BuildPreRegex =(
r'^\s*install.*',
r'^\s*chown.*',
r'^\s*chgrp.*',
)

BuildMakeRegex=(
(r'(.*make[\n ].*)',		' %{?_smp_mflags} \n'),



)

def append_line(i,regx):
    def _method(self,*args):
	for arg in args:
        	print 'append===',regx[i][1],' after = ', arg.string
	return args[0].string.strip("\n") + regx[i][1]
    return _method

def replace_line(i,regx):
    def _method(self,*args):
	for arg in args:
        	print 'replace===',arg.string,' with==',regx[i][1]
	return regx[i][1]
    return _method

def move_line(self,mo,*args):
	print 'move line : ',mo.string," to ", args[0]
	if type(args[0]) is list:
		args[0].append(mo.string)


class BuildRegx(MultiRegex):
	pass



def parsebuild(build,buildfolder,pre):
	tmp = build
	build = []

	lines = iter(tmp)
	for i,line in enumerate(lines):
		
	 	
		if matchgroupuser(lines,line,pre): continue	
		if matchBlock('cat (>|>>)\s*/.*(EOF|"EOF")','^EOF',lines,line,build,True,False) : continue
		
		if BuildRegx(BuildPreRegex,move_line).search(line,pre) : continue
		BuildRegx(BuildCDRegex,move_line).search(line,buildfolder)
		
		line = BuildRegx(BuildSubRegex,replace_line).sub(line)
		line = BuildRegx(BuildMakeRegex,append_line).sub(line)

		build.append(line)
	
	return build

InstallSubRegex = (
(r'=/',			"=${RPM_BUILD_ROOT}/"),
(r'DESTDIR=',		"DESTDIR=$RPM_BUILD_ROOT"),
(r'f ../',		"f  %_sourcedir/"),
)


PostrunRegex = [
'^\s*pwconv.*',
'^\s*grpconv.*',
"^\s*echo 'root:ping'.*",
'^\s*grub-install .*',
'^\s*build/udevadm hwdb --update.*',
'^\s*chgrp.*',
'^\s*chmod.*',
'^\s*chown.*',
'^\s*gtk-update-icon-cache.*',
'^\s*update-desktop-database.*',
'^\s*usermod.*',
'^\s*useradd.*',
'^\s*groupadd.*',
'^\s*ssh-keygen.*',
'^\s*unset public_key.*',
#'^\s*rndc-confgen.*',
'^\s*mknod.*',
'^\s*/etc/rc.d/init.d/.*',
'^exim -v -bi',
'^/usr/sbin/.*',
'.*install.*-o.*-g.*',
'.*~/.*',
'.*>>.*',
]


InstallActRegex =(
r'(?P<InstallByGroupUser>)',
r'(?P<UserSpec>)',
r'(?P<AppAct>())',
r'(?P<Append>.*>>.*)',
)

InstallSpaceFolder=(
r'(.* /.*|.*>/.*)',

)
InstallMakeInstall=(
r'.*make.*install.*',
)


class InstallRegx(MultiRegex):

	
	
	def SpaceFolder(self,mo,*args):
		line = mo.group()

		if "/dev/null" in line:
			'''
			zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
			'''
			return line
		elif "ln " in line:
			'''
			ln -sv ....
			'''
			if findfolder(line[8:]):
				#print line[8:]
				#print findfolder(line[8:])
				#print walk2(findfolder(line[8:])[0]),"level========================"
				pass
			line = line[:8].replace(' /',' ../') + line[8:].replace(' /'," ${RPM_BUILD_ROOT}/")
		
		else:
			return line.replace(' /'," ${RPM_BUILD_ROOT}/")
		
		 	
		return line

	
	
	def MakeInstall(self,mo,*args):
		line = mo.group()
		if "make modules_install" in line:
			line = line.strip("\n") + " INSTALL_MOD_PATH=$RPM_BUILD_ROOT \n"
		if "make BINDIR=${RPM_BUILD_ROOT}/sbin install" in line: 
	
			line = line.strip("\n") + " install prefix=$RPM_BUILD_ROOT \n"
		if "make -C src install" in line:
	
			line = line.strip("\n") + " ROOT=$RPM_BUILD_ROOT \n"
		if "&&" in line:
	
			line = line.strip("\n").strip("&&").strip() + " DESTDIR=$RPM_BUILD_ROOT \n"
		else:
			line = line.strip("\n") + " DESTDIR=$RPM_BUILD_ROOT \n"
		return line


def parseinstall(install,makefolders,postrun):
	tmp = install
	install = []
	lines = iter(tmp)
	trash = []

	for i,line in enumerate(lines):
	 	
		if containsAny(line,['/tools/lib/','/tools/bin/','*gdb.py']):
			
			continue
		else:
			makefolders.extend(findfolder(line))
			if matchBlock('cat >>\s*/.*(EOF|"EOF")','^EOF',lines,line,postrun,True,False): continue
			if matchBlock('cat >\s*/.*(EOF|"EOF")','^EOF',lines,line,install): continue
			if matchBlock('cat (>|>>) ~/','^EOF',lines,line,postrun) : continue
			if matchBlock('^menuentry ','^}',lines,line,trash) : continue
			#if matchPostAction(line,postrun) : continue 
			#if matchUserSettings(line,postrun) : continue 
			#if matchChangeGroupUser(line,postrun): continue
			if InstallRegx(PostrunRegex,move_line).search(line,postrun): continue
			line = InstallRegx(InstallSubRegex,replace_line).sub(line)
			line = InstallRegx(InstallSpaceFolder,SpaceFolder).sub(line)
			line = InstallRegx(InstallMakeInstall,MakeInstall).sub(line)

			if containsAny(line, ['bash udev-lfs-206-1/init-net-rules.sh']):
				install.append("mkdir -pv $RPM_BUILD_ROOT/etc/udev/rules.d/\n")
				install.append("cp -v /etc/udev/rules.d/70-persistent-net.rules $RPM_BUILD_ROOT/etc/udev/rules.d/\n")
				install.append('sed -i \'s/\"00:0c:29:[^\\".]*\"/\"00:0c:29:*:*:*\"/\' $RPM_BUILD_ROOT/etc/udev/rules.d/70-persistent-net.rules\n')
				continue

		install.append(line)
			

	return install


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
		self._summary = ""
		
		

	def makeblock(self,extra_depend=""):
		makestr = ""
		if "blfs" in self.book.link :
			
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
	#
	def rpmrequire(self):
		depend = []
		if self.dependency:
			for d in self.dependency.split():
				depend.append(shortname(d))
		return depend

	def specs(self):
		if not containsAny(self.shortname,SpecsSkipList):
			pre = []
			build = []
			install = []
			buildfolder=[]
			installfolders = []
			postrun = []
			on = 0
			specstxt = ""
			if self.commands:
				for cmd in self.commands:
					if type(cmd) is not str:
						line = self.findchild(cmd)
					else:
						line = cmd.strip()
			
					if containsAll(line, ['install','make']) and not containsAny(line,['makeinfo']) :
			
						install.extend(self.lineadd(line))
						on = 1
					elif not on:
						build.extend(self.lineadd(line))
					elif containsAll(line, ['make distclean']):
						break
					else:
						install.extend(self.lineadd(line))
				if not on:
					install =  build 
					build = []
				
				build = parsebuild(build,buildfolder,pre)
				
				install = parseinstall(install,installfolders,postrun)


				specstxt +="%define dist " + self.book.name + "\n"
				specstxt +="%define srcdir %_builddir/%{name}-%{version} \n"
				specstxt += 'Summary:    ' + str(self.page.summary if self.page.summary else self.fullname) + '\n'
				specstxt += 'Name:       ' + str(self.shortname if self.no != "6071" else "linux-API-header") + '\n'
				specstxt += 'Version:    ' + str(self.version if self.version else "1.0")+ "\n"
				specstxt += 'Release:    %{?dist}'+ self.book.version + "\n"
				specstxt += 'License:    GPLv3+'+ "\n"
				specstxt += 'Group:      Development/Tools'+ "\n"
				specstxt +=  '\n'.join('Requires:  ' + d for d in self.rpmrequire() if self.dependency ) + "\n"
				specstxt += '\n'.join('Source' + str(i) + ':    ' + line for i,line in enumerate(self.downloads)) + "\n"
				specstxt += 'URL:        ' + str(self.downloads[0].rsplit('/',1)[0]  if self.downloads else "http://" + self.page.link ) + "\n"

				specstxt += '%description'+ "\n"
				specstxt +=  str(self.page.summary if self.page.summary else self.fullname)  + "\n"
				specstxt += "%pre\n"
				specstxt += '\n'.join(str(line) for line in pre)
				specstxt += '%prep'+ "\n"
				specstxt += 'export XORG_PREFIX="/opt"\n'
				specstxt += 'export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"\n'
				#specstxt += '\n'.join('wget --no-check-certificate -nc ' + line  + ' -P %_sourcedir\n' for i,line in enumerate(self.downloads)) + "\n"
				specstxt += '''\
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac
'''
				'''if self.shortname == "vim" :
					specstxt += "%setup -q -n vim" + self.version.replace(".","")
				elif self.shortname =="udev":
					specstxt += "%setup -q -n systemd-%{version}"
				elif self.no == "6071":
					specstxt += "%setup -q -n linux-%{version}"
				elif self.downloads:
					specstxt += "%setup -q -n %{name}-%{version}"
				else:
					specstxt += ""
'''
				specstxt += '\n%build'+ "\n"
				specstxt += 'cd %{srcdir}\n'
				specstxt += ''.join(str(line)  for line in build)  + "\n"

				specstxt += '%install'+ "\n"

				specstxt += 'cd %{srcdir}\n'

				specstxt += 'rm -rf ${RPM_BUILD_ROOT}'+ "\n"

				specstxt += str(buildfolder[0] if buildfolder else "" ) + "\n"

				specstxt += '\n'.join("mkdir -pv $RPM_BUILD_ROOT" + f for f in set(installfolders)) + "\n"

				specstxt += ''.join(line for line in install)  + "\n"

				specstxt += '[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir'+ "\n"

				specstxt += '%clean'+ "\n"

				specstxt += 'rm -rf ${RPM_BUILD_ROOT}'+ "\n"
				specstxt += 'rm -rf %{srcdir}'+ "\n"

				specstxt += '%post'+ "\n"

				specstxt += '/sbin/ldconfig\n'

				specstxt += '\n'.join(line for line in postrun) 

				specstxt += '/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :'+ "\n"

				specstxt += '%preun'+ "\n"

				specstxt += '%files'+ "\n"
				specstxt += '%defattr(-,root,root,-)'+ "\n"
				specstxt += '%doc'+ "\n"
				specstxt += '/*'+ "\n"
				specstxt += '%changelog'

			return specstxt
		else:
			return None
	@run_once
	def writefunctions(self,scriptfolder):
		print "run once--------"
		if not os.path.exists(scriptfolder):
			os.makedirs(scriptfolder)
		else:
			scriptfile= scriptfolder + "/" + functionfile
			file = open(scriptfile,'wb')
			file.write(functionstr)
			file.close
	@run_once
	def rpmbuildtree(self):
		print "run once--------"
		paths = ['~/rpmbuild/BUILD','~/rpmbuild/BUILDROOT','~/rpmbuild/RPMS','~/rpmbuild/SOURCES','~/rpmbuild/SPECS','~/rpmbuild/SRPMS' ]
		for path in paths:
			dirname = os.path.expanduser(path)
			if not os.path.exists(dirname):
				os.makedirs(dirname)
	def downpack(self,targetDir):
		for link in self.downloads:
	
			os.system('wget --no-check-certificate -nc --timeout=60 --tries=5 ' + link + ' -P ' + targetDir )

	def writespecs(self):
		action = run_once(self.rpmbuildtree)
		txt = self.specs()
		if txt :
			action()
			output=os.path.expanduser("~/rpmbuild/SPECS/") +  str(self.fullname if self.no != "6071" else "linux-API-header") + ".spec"
			file = open(output, 'wb')
			file.write(txt)
			file.close

	def writescript(self,filename,scriptfolder):
		action = run_once(self.writefunctions)
		
		if not os.path.exists(scriptfolder):
			os.makedirs(scriptfolder)
		else:
			action(scriptfolder)
			scriptfile= scriptfolder + "/" + filename.strip() + ".sh"
			file = open(scriptfile,'wb')
			file.write(self.script())
			file.close
	def overruncmds(self,cmds):
		if cmds:
			self.commands = cmds
	def script(self):
		scriptstr =""
		short = self.shortname
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if containsAny(short,['nss','json','pulseaudio','libiodbc']):
			scriptstr += scriptheader1 + "pkgname=" + short + "\nversion=" + self.version + "\nexport MAKEFLAGS='-j 1'\n" 
		else:
			scriptstr += scriptheader1 + "pkgname=" + short + "\nversion=" + self.version + "\nexport MAKEFLAGS='-j 4'\n" 
					
		if self.downloads:
			for link in set(self.downloads):
				
				if "blfs" in self.book.link and 'wget' not in short and 'openssl' not in short:
					
					scriptstr += "nwget " + link + "\n"
				else:
					pass
			scriptstr += "preparepack \"$pkgname\" \"$version\" " + parselink(self.downloads[0]) + "\n"
			scriptstr += "cd ${SOURCES}/${pkgname}-${version} \n"
		if self.commands:
			for line in self.commands:
				#print type(line),line
				#if type(line) is not str:
				#	go = 1


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
	#
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
			self._shortname = shortname(self.name)
		return self._shortname
	@property
	def packsoup(self):
		if not self._soup:
			self._soup =  self.page.pagesoup
		return self._soup




class Page:
	def __init__(self,pageNo,pagename,pagelink,chapter,book):
		self.no= pageNo
		self.name = pagename
		self._packages = []
		self.book = book
		self.link = self.book.bookdir + "/" + pagelink
		self.chapter = chapter
		self._soup = None
		self._summary = ""

	def show(self):
		print self.no,self.name,self.link

	@property
	def summary(self):
		if not self._summary:
			summary = str(''.join(re.sub("[ \n]+"," ",''.join(i).encode('utf-8')) for i in self.pagesoup.xpath(".//div[@class='package']/p[1]//text()")))
			if summary :
				self._summary = summary
			else:
				self._summary = ""
		return self._summary
	
	def parsedownload(self,subsoup):
		download_link = []
		short = shortname(self.name)
		
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if self.book.wget_file_list:

			link = grep('/' + short + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.wget_file_list)
			
			if link:
				download_link.append(link)
		if download_link:
			#print download_link
			return download_link
		else:
			
			uls=subsoup.xpath(".//div[@class='itemizedlist']/ul[@class='compact']")
			counter=0
			if uls:
		
				for ul in uls:
					for alink in ul.xpath(".//a[@class='ulink']"):
						dlink = alink.attrib['href'].strip()
						if str(dlink ).endswith('/') or "certdata" in str(dlink ) or str(dlink ).endswith('.html') :
							pass  
						else:
							download_link.append(dlink)

			return download_link

	def parsedependency(self,depsoup):

		ps=depsoup.xpath(".//p[contains(@class,'required') or contains(@class,'recommended')]")
		noskip = 1 
		if ps:
			dependstr=""

			for p in ps:
				
				for node in p.xpath("./node()"):
					
					try:
						
						#dname = NormName(re.sub(r"[\x90-\xff]", "",node.xpath("./@title")[0]))
						dname = node.xpath("./@title")[0]
						#print dname,'dnametitle',noskip,node.xpath("./@title")
						if noskip:
							pkgname = NormName(dname)
							
							if containsAny(pkgname,["x-window-system"]):
								short =  "x-window-system-environment"
							elif containsAny(pkgname,['udev-installed-lfs-version']):
								short = 'udev-extras-from-systemd'
							else:
								short = shortname(dname)
							ver = version(dname)	
							if ver:
								dependstr += short + "-"  + ver + " "
							else:
								dependstr += short + " "
							
						noskip = 1
					except (AttributeError,IndexError):
						try:
							dname = node.strip()
							
							if "or" == dname:
								noskip = 0
							continue
						except AttributeError:
							continue
						
							
					
		else:
			dependstr=""

		return dependstr


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
			soup = etree.HTML(urllib2.urlopen(link).read())
	
			alinks = soup.xpath(".//a/@href")
			for alink in alinks:
				if "tar.gz" in alink:
					packlink = alink.strip()
	
			if packlink:
				match = re.search('(http://[^/]+/)',link) #http://search.cpan.org/
				packlink=match.group(1) +  packlink.strip("/") + "\n"
				file = open(perl_pack_lists,"a")
				file.write(packlink)
				file.close
				return packlink
			else:
				return ""

	
	def parseperldownload(self,link):
		
		if link:#.attrib['href']:
			#link = str(alink.attrib['href'].strip())
			 
			if link.endswith('/'): #parse external link :http://search.cpan.org/~gaas/LWP-Protocol-https/
			
				return str(self.parseexternal(link))
				

			elif   ".html" in link:# same page no need to parse,ex:# /www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
							      #within BLFS, no need to parse
				return None

			else:                               # otherwises, need to parse all 

				return link

	
	def parseperl(self,plist,i):
		global counter
		#link =  "www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html"
		link = self.book.perl_modules_link
		
		soup = etree.HTML(open(link).read())#BeautifulSoup(open(link).read())

		divs = soup.xpath(".//div[@class='package']/div[@class='itemizedlist']")#(findNextSibling(attrs={'class':'itemizedlist'})
		for div in divs:
			if div != None :
				
				
				self.perldepend(div,None,plist,i,[])
				i = counter
	

	
	def perldepend(self,div,link,plist,i,lastdown):
		'''
		div : next div to parse
		link: next link of div to parse ex: ['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']
		
		'''
		global counter
		nextdown = deque()
		dependency=""			
		downloads=[]					

		lis = div.xpath("./ul/li")
		#encode-locale-1.03  html-form-6.03  http-cookies-6.01  http-negotiate-6.01  net-http-6.06  www-robotrules-6.02  http-daemon-6.01  file-listing-6.04
		
		for li in lis:
			for a in li.xpath("./p/a"):
				try:
					url = a.attrib['href'].strip()
				except (KeyError,AttributeError):
					continue
			
			#print "URL     :",url

			if link != None and ".html" in url: # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
						     # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/postlfs/openssl.html
				downloads = []
	
			else:        #http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz/ TITLE
				downloads = filter(None,[ self.parseperldownload(url) ])
			

			if downloads:
				#if download exists, parse its download link as dependency
				packname = parselink(downloads[0]).strip(".tar.gz")
			
				dependency += fullname(packname) + "  "
			else:   # or parse its text as dependency 
				dependency += fullname(li.xpath("./p/a//text()")[0].strip()) + " "
		

			if downloads and not li.xpath("./div"):
				# li has not div descendants, mean there is no dependency along with it.
				packname = fullname(packname)
				i += 1
				packno = packno = str(self.no) + str(i)
				'''print "--------------------"
				print '===  down:',downloads
				print ":packname:",packname
				print ":packno  :",packno'''
				plist.append(Package(packno,packname,perlcmd,downloads,"",self,self.chapter,self.book))
				counter =  i
			elif downloads:
				for down in downloads:
					nextdown.append(down)
		
		if link is not None:# previous parents exists,['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']

			thisdown = lastdown.popleft() 
			packname = fullname(parselink(thisdown).strip(".tar.gz"))
	
			i += 1
			packno = packno = str(self.no) + str(i)
			'''print "--------------------"
			print '     down:',thisdown
			print ":packname:",packname
			print ":packno  :",packno
			print "depend   :",dependency'''
			plist.append(Package(packno,packname,perlcmd,[thisdown],dependency,self,self.chapter,self.book))
			counter = i

		nextdiv = div.xpath("./ul/li/div[@class='itemizedlist']")# next div to parse
		for ndiv in nextdiv:  # Iterate over div of class itemizedlist
			
			isnextdiv = ndiv.xpath("./preceding-sibling::*/a/text()")
			# Tiltle of next div need to be iterate, for example, Crypt::SSLeay-0.64
			#print "next link:",isnextdiv
			if ndiv is not None:
				self.perldepend(ndiv,isnextdiv,plist,i,nextdown)

	
	@property
	def pagesoup(self):
		if not self._soup:
			self._soup = etree.HTML(open(self.link).read())
		return self._soup

	def parsecmds(self,lines,cmds):
		
		for line in lines:
			if line is not None:
				
				prev = ''.join(l.strip() for l in line.xpath("../preceding-sibling::p[1]//text()"))
				thisline = ''.join(str(l) for l in line.xpath(".//text()")) + "\n"
				
				if containsAny(prev, ['doxygen','Doxygen','texlive','TeX Live','Sphinx']) and not containsAny(prev,['Install Doxygen']):
					
					pass
				elif   containsAny(prev, ['documentation','manual']) and containsAny(prev, ['If you','API','alternate''optional','Sphinx','DocBook-utils','Additional','PDF','Postscript']) and  not containsAny(prev,['If you downloaded','Man and info reader programs','The Info documentation system']):
					
					pass
				elif line.xpath("../preceding-sibling::p//a[@title='BLFS Boot Scripts']"):
					bootscript = self.book.search("BLFS")
					#bootscript[0].overruncmds([''.join(str(l) for l in line.xpath(".//text()")) + "\n"])
					#print bootscript[0].commands
					#print bootscript[0].script()
					cmds.append("mkdir /etc\n")
					cmds.append("mkdir  " + bootscript[0].shortname + "\n")
					cmds.append("tar xf ../" + parselink(bootscript[0].downloads[0])+" -C " + bootscript[0].shortname + " --strip-components 1\n")
					cmds.append("cd " + bootscript[0].shortname+"\n")
					cmds.append(thisline)

				else:
					cmds.append(thisline)
			else:
				print line,'============================'
				cmds.append(line.xpath(".//text()") + "\n")

			
	@property
	
	def packages(self):
		
		print "lazy generating packages :" + shortname(self.name)
		if not self._packages:
			
			pagesoup = self.pagesoup
			string = shortname(self.name)
			
			if string == "python-modules" or string == "xorg-drivers" :
				
				headers = pagesoup.xpath(".//h2[@class='sect2']") 
			else:
				headers = pagesoup.xpath(".//h1[@class='sect1']")
			plist = [] 
			for i,header in enumerate(headers):
			 
				
				parent =header.xpath(".//parent::*")[0]
				lines=parent.xpath(".//kbd[@class='command']")
				cmds =[]
				downs = []
				downs =  self.parsedownload(parent)
				
				self.parsecmds(lines,cmds)
				
				
				if cmds or downs:
					#packname = header.xpath("//h1[@class='sect1']//text()[2]")[0]
					packname = ''.join(str(l) for l in header.xpath(".//text()")) 
					
					#if string == "libvpx":
					#	packname = string + '-' + version(self.name).replace('v','')

					if string == 'xkeyboardconfig':
						packname = 'xkeyboard-config' + "-" + version(self.name)
					if string == "perl-modules":
						
						self.parseperl(plist,i)
						i = counter
					else:
						packno = str(self.no) + str(i+1)
						
						depends = ""
						
						if "blfs" in self.book.link:
							depends = self.parsedependency(parent)
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
			

	def listpage(self,pagesection,tag):
		if not self._pages:
			plist = []
			pagesgrp = pagesection.xpath(".//following-sibling::*")
			for pageul in pagesgrp:
				pages = pageul.xpath(tag)
				for i,p in enumerate(pages):
					 
					plist.append(Page(str(self.no) + str(i+1).zfill(2),p.text,p.attrib['href'] ,self,self.book))
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
	@$(call echo_message, Building)
	@time source /etc/profile  && make  mk-''' + self.name + '''
	@touch $@
mk-''' + self.name + " :  $(" + self.name + ")\n\n"
		return mkstr
	@property
	
	def pages(self):
		if not self._pages:
			print "lazy generating chapters for:" + self.name
			self.listpage(self.soup,".//a")
		return self._pages

	
	
class Book:
	
	
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
				for p in pack:
					for cmd in p.commands:
						
						match = re.search('/(udev-lfs(-([0-9.]+))+)[^/]*\.tar\.((bz2)|(xz)|(gz))$',cmd,re.IGNORECASE)
						if match:
							self._udev_version = match.group(1)
							break
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
			
			soup = self.booksoup.xpath('.//a[contains(text(),"' + "Perl Modules" + '")]')
			
			link = soup[0].attrib['href']
			self._perl_modules_link = self.bookdir + "/" + link 
		return self._perl_modules_link

	def listchapter(self,booksoup,tag):
		if not self._chapters:
			clist = []
			chapters =  booksoup.xpath(tag)
			
			for i,ch in enumerate(chapters):
				
				for name in ch.xpath(".//text()"):
					if name.strip():
						chname = name.strip()
				try:
					chno = re.search("^\s*([0-9]{1,2})",chname).group(1)
				except (AttributeError,IndexError):
					chno = 0 
				
				tmpch = Chapter(chno,chname,ch,self)
				clist.append(tmpch)
			self._chapters = clist
		 
	def findchapter(self,chno):
	
		for ch in self.chapters:

			if str(ch.no) == str(chno):
				
				return ch
		return None

	def search(self,name):
		print name
		soup = self.booksoup.xpath('.//a[contains(translate(., "ABCDEFGHJIKLMNOPQRSTUVWXYZ", "abcdefghjiklmnopqrstuvwxyz"),"' + name.lower() + '")]/../../../h4//text()')
		
		chno = 0
		counter = 0
		chapters = []
		chnos = []
		packs = []
		print len(soup)
		if soup:
			for a in soup:
				txt= a.strip()
				if txt is not None:
					chapters.append(txt)
			
			for chapter in chapters:
				
				mat= re.search("^\s*([0-9]{1,2})",chapter)
				if mat:

					chnos.append(int(mat.group(1))) 
			
			for chno in chnos:
				
				dchapter = self.findchapter(chno)
				
				if dchapter:
					for i,page in enumerate(dchapter.pages):
						
						if re.search(name.lower(),NormName(page.name),re.MULTILINE):
					
							counter= i
							
							break
				
					for pack in dchapter.pages[counter].packages:
						packs.append(pack)
			
		if packs is None:
			return None
		else:
			return packs
	
	@property
	def version(self):
		if not self._version:
			version=self.booksoup.xpath("//h2[@class='subtitle']")
			if version:
				for v in version:
					self._version = v.text.replace("Version","").strip()
		return self._version

	@property
	def booksoup(self):
		if self._soup is None:
			try:
				self._soup = etree.HTML(open(self.link).read())#soupparser.fromstring(open(self.link).read())[1]
			except IOError:
				os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent " + self.link)
				self._soup = etree.HTML(open(self.link).read()) #soupparser.fromstring(open(self.link).read())[1]
		
		return self._soup

	@property
	
	def chapters(self):
		if not self._chapters:
			print "lazy generating chapters for :",self.name
			self.listchapter(self.booksoup,".//h4")
		return self._chapters



def blfstest():
	#
	
	link = "www.linuxfromscratch.org/blfs/view/stable/index.html"
	blfs = Book(link, Book("www.linuxfromscratch.org/lfs/view/stable/index.html"))
	
	
	#print blfs.udev_version
	#print "-----------",grep('/XML-SAX-Expat-([0-9.]+)[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,lfs.perl_packs)
	packs = blfs.search("openssh")
	#print blfs.wget_file_list
	#pack = blfs.chapters[13].pages[19].packages[6]
	#lfs.search("Changing\s*Ownership")
	#pack = blfs.search("totem")
	#print '---------------------',page
	#page.populate()
	#print blfs.perl_modules_link,"link"
	#for pack in page.packages:
	#print len(packs),"len"
	for ch in blfs.chapters:
		print ch.name,ch.no
		for page in ch.pages:
			#print page.summary
			pack = page.packages
			if pack:
				for package in pack:
					#for line in package.commands:
					#	if re.search('cat > ~/[^\\bEOF\\b]*EOF',line,re.MULTILINE):
								#print line
					#			print "==========="
					#	if re.search('cat\s*>[^\\bEOF\\b]*<<\s*(EOF|"EOF")',line,re.MULTILINE):
					#		print re.sub("cat\s*(>|>>)\s*/","cat \g<1> $RPM_BUILD_ROOT/",line) 
					#		print "==========="
					#print package.fullname
					package.writespecs()
					#print package.specs()
	
						

'''
for pack in packs:
	
		print "name:",pack.name
		print "short:",pack.shortname
		print "version:",pack.version
		#print "command:",pack.commands
		#print pack.downloads
		#print pack.dependency
		print "------------------------------------------------"
		print pack.specs()

					 
	for pack in packs:
	
		print "name:",pack.name
		print "short:",pack.shortname
		print "version:",pack.version
		#print "command:",pack.commands
		print pack.downloads
		print pack.dependency
		print "------------------------------------------------"
		print pack.specs()
		print pack.script()
		print "------------------------------------------------"
for pack in packs:
	
		print "name:",pack.name
		print pack.shortname
		print pack.version
		print "command:",pack.commands
		print pack.downloads
		print pack.dependency
		print "------------------------------------------------"
		print pack.specs()
		print pack.script()
		print "------------------------------------------------"
		pack.writespecs()
		pack.writescript()







		
	for ch in blfs.chapters:
		print ch.name,ch.no
		for page in ch.pages:
			pack = page.packages
			if pack:
				for package in pack:
					#print package.specs()
					package.writespecs()

	if pack:
		print pack.name
		print pack.shortname
	 	print pack.version
		print pack.downloads
		print pack.writespecs()
		
	#print "downn=",pack.downloads
	#print "depend=",pack.dependency
	print "------------------------"

		page = lfs.search('wget')
	if page:
		print page.name,page.dependency
'''


def lfstest():
	link = "www.linuxfromscratch.org/lfs/view/stable/index.html"
	lfs = Book(link)
	#packs = lfs.search("network")
	
	for ch in lfs.chapters:
		print ch.name,ch.no

		for page in ch.pages:
			
			pack = page.packages
			if pack:
				for package in pack:
					
					#		print "==========="
						
					#print package.version
					#print package.shortname
					#print package.commands
					#print package.specs()
					package.writespecs()
	
'''	
for pack in packs:
		if pack:
			print pack.name
			print pack.shortname
		 	print pack.version
			print pack.page.summary
			print pack.dependency
			print pack.script()
			#print pack.specs()
					#print package.dependency
					#print package.script()
					for i in package.commands:
						print i
		if ch.no > 5 :
			for page in ch.pages:
				pack = page.packages
				if pack:
					for package in pack:
						#print package.specs()
						package.writespecs()
	
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
blfstest()

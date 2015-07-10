#!/usr/bin/env python
#1.12 support lfs 7.5
#1.11 regex stablized
#1.10 mass regex applied
#1.09 migrate beautifulsoup to lxml
#1.08 add generate-specs function
#1.07 replace "make oldconfig" with "make localmodconfig"

import urllib2
import os,re,sys,glob,time
import binascii,platform
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
from collections import deque
from os import error, listdir
from os.path import join, isdir, islink
from lxml import etree
from settings import *
from consts import *
functionfile = "functions.sh"

scriptheader1='''\
#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/%s'''%functionfile

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

CWD=os.path.dirname(os.path.realpath(__file__))



perl_pack_lists= "perl_pack_lists"

counter = 0



perlcmd= ['perl Makefile.PL && make && make install\n']

untar = '''\
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


def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]


def NormName(name):
	"""To normalize the package name, trim off space,unicode,&nbsp,tab,return,etc."""
	namestrip= re.compile("[\x90-\xff]|\\b&nbsp;\\b|[\s\~\:\+\-\_\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
	return namestrip.sub("-",name).lower().strip("-")

def shortname(name):
	"""To match package short name without version number. """
	pkgname =  NormName(name)
	namematch = re.search("([a-zA-Z]+[a-zA-Z0-9]*(?:-[^-.\d]*[0-9]*[a-zA-Z]+[0-9]*)*)(?![.\d]+)",pkgname)
	#"^([a-zA-Z0-9]+(-[0-9]*[a-zA-Z]+[0-9]*)*)"	
	#"([a-zA-Z]+[a-zA-Z0-9]*(-[^.\d][0-9]*[a-zA-Z]+[0-9]*)*)"
	shortname = namematch.group(1)
	return shortname

def version(name):
	"""To match package version number. """
	versionmatch = re.search("-([\w]*[0-9.]+[\w]*)",name.strip(),re.MULTILINE)
	#no $, GCC-4.8.2 - Pass 1 will fail
	#change [0-9.]* to [0-9.]+ as Tie-IxHash-1.23 will parse wrongly
	#blfs-bootscripts-20130908.tar.bz2
	#-([a-zA-Z0-9]*[0-9.]+[a-zA-Z0-9]*)
	try:
		version = versionmatch.group(1)
	except AttributeError:
		version = ""
	return version

def fullname(name):
	"""To concat package name and version to make a full name. """
	ver = version(name)
	if ver:
		return shortname(name) + "-" + version(name)
	else:
		return shortname(name)



def parselink(download_link):
	"""To match package file name(XXX.(tar).zip|bz|xz) in the download link """

	packname=""
	if download_link:
		packmat = re.search("/([-.\w]*[^/]*\.*(tar)*\.*((zip)|(tar)|(bz2)|(xz)|\
		(gz)|(tgz)|(pm))+$)",download_link)
	
		try:
			packname = packmat.group(1)
		except AttributeError:
			packname = ""
	return packname

def grep(pattern,files):
	"""To mimic the linux command 'grep' """
	for line in files:

		if re.search(pattern,line,re.IGNORECASE):
		
			return line
def foldername(str):
	"""To get the folder name from string """
	if os.path.isdir(str):
		return str
	else:
		 return os.path.dirname(str)

def findfolder(line):
	"""To match folder name from command line """
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
	"""Make sure one specific function run only once for each instance """
	def wrapper(*args, **kwargs):
		if not wrapper.has_run:
			wrapper.has_run = True
			return f(*args, **kwargs)
	wrapper.has_run = False
	return wrapper





class Package(object):
	''' Basic class to house all the LFS package
		no: package number/order from LFS book
		name: package name 
		cmds: package installation commands line from LFS book
		downs: link to download package online
		depends: package dependencies, very important part for current Linux|LFS  philosophy
		page: the page where contains the packages installation instruction, one page might have several pages.
		chapter: the chapters where the page coming from
		book: LFS online book link. Now only support LFS and BLFS 
	'''
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

		makestr += "\n\n" + packtgt + " : " + \
				   extra_depend + " " + self.dependency  + "\n" + packmakeblock
		return makestr.encode("utf-8")
	#
	def rpmrequire(self):
		depend = []
		if self.dependency:
			for d in self.dependency.split():
				depend.append(shortname(d))
		return depend

	def specs(self):
		''' Generate specs file for one specific package

			Example: file-5.17.spec
			%define dist LFS
			%define srcdir %_builddir/%{name}-%{version} 
			Summary:     The File package contains a utility for determining the type of a given file or files. 
			Name:       file
			Version:    5.17
			Release:    %{?dist}7.5
			License:    GPLv3+
			Group:      Development/Tools

			Source0:    ftp://ftp.astron.com/pub/file/file-5.17.tar.gz

			URL:        ftp://ftp.astron.com/pub/file
			%description
			 The File package contains a utility for determining the type of a given file or files. 
			%pre
			%prep
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

			%build
			cd %{srcdir}
			./configure --prefix=/usr
			make %{?_smp_mflags} 

			%install
			cd %{srcdir}
			rm -rf ${RPM_BUILD_ROOT}


			make install DESTDIR=${RPM_BUILD_ROOT} 


			[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
			%clean
			rm -rf ${RPM_BUILD_ROOT}
			rm -rf %{srcdir}
			%post
			/sbin/ldconfig
			/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
			%preun
			%files
			%defattr(-,root,root,-)
			%doc
			/*
			%changelog
		'''
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
			
					if containsAll(line, ['install','make']) \
						and not containsAny(line,['makeinfo']) :
			
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
				specstxt += 'Summary:    ' + \
							str(self.page.summary if self.page.summary else self.fullname) + '\n'
				specstxt += 'Name:       ' + \
							str(self.shortname if self.no != "6071" else "linux-API-header") + '\n'
				specstxt += 'Version:    ' + \
							str(self.version if self.version else "1.0")+ "\n"
				specstxt += 'Release:    %{?dist}'+ self.book.version + "\n"
				specstxt += 'License:    GPLv3+'+ "\n"
				specstxt += 'Group:      Development/Tools'+ "\n"
				specstxt += '\n'.join('Requires:  ' + d 
							for d in self.rpmrequire() if self.dependency ) + "\n"
				specstxt += '\n'.join('Source' + str(i) + ':    ' + line 
							for i,line in enumerate(self.downloads)) + "\n"
				specstxt += 'URL:        ' + \
							str(self.downloads[0].rsplit('/',1)[0]  
							if self.downloads else "http://" + self.page.link ) + "\n"

				specstxt += '%description'+ "\n"
				specstxt +=  str(self.page.summary 
							 if self.page.summary else self.fullname)  + "\n"
				specstxt += "%pre\n"
				specstxt += '\n'.join(str(line) for line in pre)
				specstxt += '%prep'+ "\n"
				specstxt += 'export XORG_PREFIX="/opt"\n'
				specstxt += 'export XORG_CONFIG="--prefix=$XORG_PREFIX  \
							--sysconfdir=/etc --localstatedir=/var --disable-static"\n'

				specstxt += untar

				specstxt += '\n%build'+ "\n"
				specstxt += 'cd %{srcdir}\n'
				specstxt += ''.join(str(line)  for line in build)  + "\n"

				specstxt += '%install'+ "\n"

				specstxt += 'cd %{srcdir}\n'

				specstxt += 'rm -rf ${RPM_BUILD_ROOT}'+ "\n"

				specstxt += str(buildfolder[0] if buildfolder else "" ) + "\n"

				specstxt += '\n'.join("mkdir -pv ${RPM_BUILD_ROOT}" + f for f in set(installfolders)) + "\n"

				specstxt += ''.join(line for line in install)  + "\n"

				specstxt += '[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir'+ "\n"

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
		''' to build the folder need for rpm build, run only once'''
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
		''' Build folder structure for rpmbuild, run only once '''
		print "run once--------"
		paths = ['~/rpmbuild/BUILD','~/rpmbuild/BUILDROOT','~/rpmbuild/RPMS',
                '~/rpmbuild/SOURCES','~/rpmbuild/SPECS','~/rpmbuild/SRPMS' ]
		for path in paths:
			dirname = os.path.expanduser(path)
			if not os.path.exists(dirname):
				os.makedirs(dirname)
	def downpack(self,targetDir):
		for link in self.downloads:
	
			os.system('wget --no-check-certificate -nc --timeout=60 --tries=5 ' 
			           + link + ' -P ' + targetDir )

	def writespecs(self):
		action = run_once(self.rpmbuildtree)
		txt = self.specs()
		if txt :
			action()
			output=os.path.expanduser("~/rpmbuild/SPECS/") + \
				   str(self.fullname if self.no != "6071" else "linux-API-header") + ".spec"
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
		''' Generate shell script file for provisioning package 
		Example: 5201-file.sh
		#/bin/bash
		set +h
		set -e

		SOURCES=$LFS/sources
		DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
		source ${DIR}/functions.sh
		pkgname=file
		version=5.17
		export MAKEFLAGS='-j 4'
		download()
		{
		:
		}
		unpack()
		{
		preparepack "$pkgname" "$version" file-5.17.tar.gz
		cd ${SOURCES}/${pkgname}-${version} 

		}
		build()
		{
		./configure --prefix=/tools

		make



		make install

		}
		clean()
		{
		cd ${SOURCES}
		rm -rf ${pkgname}-${version} 
		rm -rf ${pkgname}-build
		}
		download;unpack;build;clean
		'''
		scriptstr =""
		short = self.shortname
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if containsAny(short,['nss','json','pulseaudio','libiodbc']):
			scriptstr += scriptheader1 + "\npkgname=" + short + "\nversion=" + \
						 self.version + "\nexport MAKEFLAGS='-j 1'\n" 
		else:
			scriptstr += scriptheader1 + "\npkgname=" + short + "\nversion=" + \
                         self.version + "\nexport MAKEFLAGS='-j 4'\n" 
		scriptstr += "download()\n{\n"		
		if self.downloads and not self.downloads[0].endswith(".patch"):
			tmp = ""
			for link in set(self.downloads):
				
				if "blfs" in self.book.link and 'wget' not in short and 'openssl' not in short:
					
					scriptstr += "nwget " + link + "\n"
				else:
					tmp = ":"
			
			scriptstr += tmp
		else:
			scriptstr +=  ":"
		scriptstr += "\n}\nunpack()\n{\n"
		if self.downloads and not self.downloads[0].endswith(".patch"):
			scriptstr += "preparepack \"$pkgname\" \"$version\" " + parselink(self.downloads[0])
			scriptstr += "\ncd ${SOURCES}/${pkgname}-${version} \n"
		else:
			scriptstr +=  "\ncd ${SOURCES} \n"

		scriptstr += "\n}\nbuild()\n{\n"
		if self.commands:
	
			allline = '\n'.join(line for i,line in enumerate(self.commands))

			lastline = allline

			line = self.modify_line(allline)
			if lastline != line:

				pass
			scriptstr += line

		else:
			scriptstr +=  ":"
		scriptstr += "\n}\n"

		if self.downloads:	
			scriptstr += "clean()\n{\ncd ${SOURCES}\nrm -rf ${pkgname}-${version} \
						  \nrm -rf ${pkgname}-build\n}\n"
		scriptstr += str( "download;unpack;build;clean\n" 
						   if self.downloads else  "download;unpack;build\n" )
		return scriptstr


	
	def findchildj(self,tag):
		''' '''
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
	def match_block(self,start,end,line,lst,cont=True):
		bregx = re.compile(r"'" + start + "(\n*[^" + end + "]*\n*)*" + end + ")'", re.MULTILINE)
		pass
	
	def modify_line(self,line):
		''' do some skip/ regex / replace job(string manipulation) for command blocks'''

	 	if self.book.name == "BLFS" :
			ignorelist = blfsignorelist
			globalreplace = blfsreplace
			globalregx = blfsregx
		else:
			ignorelist = lfsignorelist
			globalreplace = lfsreplace
			globalregx = lfsregx

		nline = ''
		for l in line.split("\n"):
			if containsAny(l,ignorelist):
				print l,'in igore'
				pass 
			else:
				nline += l + "\n"
		line = nline
		line = BookReplace(globalreplace,make_dummy).sub(line)

		line = BookRegex(globalregx,make_dummy).sub(line)

		return line

			


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
						self.delete_log += "-"*20 + self.name + "-"*20
						self.delete_log += "Delete line : " + str(i) + " : " + line + " from :\n"
						self.delete_log += block + "\n"
						
						pass
			   		else:
				
						lst.append(self.massreplaceline(line) + "\n")
		
		return lst
	#
	def massreplaceline(self,string):
		'''The actual function of mass regex '''
 		if "blfs" in self.book.link :
			globalreplace = blfsreplace
			globalregx = blfsregx
		else:
			globalreplace = lfsreplace
			globalregx = lfsregx

		laststr = string 
		string = BookReplace(globalreplace,make_dummy).sub(string)
		
		if string != laststr:
				self.replace_log += "\nOrigin    : " + laststr + "\n"
				
				self.replace_log += "Replacing : " + laststr + " with : " + string  + "\n"
				#
				self.replace_log += "-"*50

		laststr = string 
		string = BookRegex(globalregx,make_dummy).sub(string)
		if string != laststr:
				self.replace_log += "\nOrigin    : " + laststr + "\n"
				self.replace_log += "Replacing : " + laststr + " with : " + string  + "\n"

				self.replace_log += "-"*50

		
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




class Page(object):
	''' Page class to simulate one page of LFS book
		PageNo: page order from LFS book
		pagename: page name 
		pagelink: page link
		chapter: the chapter page belongs to 
		book: the book the chapter belongs to 
		
		use xpath to analyse html page 
	'''
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
			summary = str(''.join(re.sub("[ \n]+"," ",''.join(i).encode('utf-8')) 
 						  for i in self.pagesoup.xpath(".//div[@class='package']/p[1]//text()")))
			if summary :
				self._summary = summary
			else:
				self._summary = ""
		return self._summary
	
	def parsedownload(self,subsoup):
		''' parse download link from page, http://www.aaa.com/bbb.tar.gz '''
		download_link = []
		short = shortname(self.name)
		
		if  "libstdc" in short:
				short = "gcc"
		if "udev" in short:
				short = "systemd"
		
		if self.book.wget_file_list:

			link = grep('/' + short + '-[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.wget_file_list)
			
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
						if str(dlink ).endswith('/') \
							or "certdata" in str(dlink ) \
							or str(dlink ).endswith('.html') :
							pass  
						else:
							download_link.append(dlink)

			return download_link

	def parsedependency(self,depsoup):
		''' parse dependeies name from page with xpath  '''
		ps=depsoup.xpath(".//p[contains(@class,'required') or contains(@class,'recommended')]")
		noskip = 1 
		if ps:
			dependstr=""

			for p in ps:
				
				for node in p.xpath("./node()"):
					
					try:
						
						
						dname = node.xpath("./@title")[0]
						
						if noskip:
							pkgname = NormName(dname)
							
							if containsAny(pkgname,["x-window-system"]):
								short =  "x-window-system-environment"
							elif containsAny(pkgname,['udev-installed-lfs-version']):
								short = 'udev-extras-from-systemd'
							elif  'xorg-build-environment' in pkgname:
								short = 'introduction-to-xorg-7.7'
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
		''' search the package on cpan.org and get the download link  '''
		
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
		''' Decide what kind of download link it is , and take relative action '''
		if link:#.attrib['href']:
			#link = str(alink.attrib['href'].strip())
			 
			if link.endswith('/'): 
				#parse external link :http://search.cpan.org/~gaas/LWP-Protocol-https/
			
				return str(self.parseexternal(link))
				

			elif   ".html" in link:
				# same page no need to parse,
				#ex:# /www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
				#within BLFS, no need to parse
				return None

			else:# otherwises, need to parse all 

				return link

	
	def parseperl(self,plist,i):
		''' For perl package only, parse perl pacakge  '''
		global counter
		#link =  "www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html"
		link = self.book.perl_modules_link
		
		soup = etree.HTML(open(link).read())#BeautifulSoup(open(link).read())

		divs = soup.xpath(".//div[@class='package']/div[@class='itemizedlist']")
		#(findNextSibling(attrs={'class':'itemizedlist'})
		for div in divs:
			if div != None :
				
				
				self.perldepend(div,None,plist,i,[])
				i = counter
	

	
	def perldepend(self,div,link,plist,i,lastdown):

		'''
			For perl package only, parse perl dependencies 
		'''
		'''
		div : next div to parse
		link: next link of div to parse ex: ['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']
		
		'''
		global counter
		nextdown = deque()
		dependency=""			
		downloads=[]					

		lis = div.xpath("./ul/li")
		#encode-locale-1.03  html-form-6.03  http-cookies-6.01  http-negotiate-6.01 
		# net-http-6.06  www-robotrules-6.02  http-daemon-6.01  file-listing-6.04
		
		for li in lis:
			for a in li.xpath("./p/a"):
				try:
					url = a.attrib['href'].strip()
				except (KeyError,AttributeError):
					continue


			if link != None and ".html" in url: 
				# /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
				# /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/postlfs/openssl.html
				downloads = []
	
			else:#http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz/ TITLE
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

				plist.append(
				Package(packno,packname,perlcmd,downloads,"",self,self.chapter,self.book))
				counter =  i
			elif downloads:
				for down in downloads:
					nextdown.append(down)
		
		if link is not None:
			# previous parents exists,['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']

			thisdown = lastdown.popleft() 
			packname = fullname(parselink(thisdown).strip(".tar.gz"))
	
			i += 1
			packno = packno = str(self.no) + str(i)

			plist.append(
			Package(packno,packname,perlcmd,[thisdown],dependency,self,self.chapter,self.book))
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
		''' Parse  pacakge command block, cornerstone for this script '''
		for line in lines:
			if line is not None:
				
				prev = ''.join(l.strip() for l in line.xpath("../preceding-sibling::p[1]//text()"))
				thisline = ''.join(str(l) for l in line.xpath(".//text()")) + "\n"
				#make line extend two line into one line
				thisline =  re.compile(r'\s*\\\n\s*',re.MULTILINE).sub(' ',thisline)
				if containsAny(prev, ['doxygen','Doxygen','texlive','TeX Live','Sphinx']) \
				    and not containsAny(prev,['Install Doxygen']):
					
					pass
				elif containsAny(prev, ['documentation','manual']) and \
					 containsAny(prev, ['If you','API','alternate''optional',
										  'Sphinx','DocBook-utils','Additional',
										  'PDF','Postscript']) and  \
					 not containsAny(prev,['If you downloaded',
                                          'Man and info reader programs',
											'The Info documentation system']):
					
					pass
				elif line.xpath("../preceding-sibling::p//a[@title='BLFS Boot Scripts']"):
					bootscript = self.book.search("BLFS")

					
					cmds.append("mkdir /etc\n")
					cmds.append("mkdir  ${SOURCES}/" + bootscript[0].shortname + "\n")
					cmds.append("cd ${SOURCES}/" + bootscript[0].shortname + "\n")
					cmds.append("tar xf ../" + parselink(bootscript[0].downloads[0])+ 
														  "  --strip-components 1\n")

					cmds.append(thisline)

				else:
					cmds.append(thisline)
			else:
				
				cmds.append(line.xpath(".//text()") + "\n")

			
	@property
	
	def packages(self):
		''' instanctiate package class on demand, as it's very costy'''
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
					
					packname = ''.join(str(l) for l in header.xpath(".//text()")) 

					#if 'xkeyboardconfig' in string:
					#	packname = 'xkeyboard-config' + "-" + version(self.name)
					# Change in lfs 7.5
					if string == "perl-modules":
						
						self.parseperl(plist,i)
						i = counter
					else:
						packno = str(self.no) + str(i+1)
						
						depends = ""
						
						if "blfs" in self.book.link:
							depends = self.parsedependency(parent)
						plist.append(Package(
											packno,
											packname,
											cmds,
											downs,
											depends,
											self,
											self.chapter,
											self.book))
			self._packages = plist
		return self._packages
						

class Chapter(object):
	'''
	Chapter class to simulate chapter object from LFS book.
	no: chapter number/order
	name: chapter name
	section: chapter section
	book: which book chatper belongs to 
	'''
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
					 
					plist.append(
								Page(str(self.no) + str(i+1).zfill(2),
								p.text,
								p.attrib['href'] ,
								self,
								self.book))
			self._pages = plist

	def addpage(self,page):
		self._pages.append(page)


	def normname(self,name):
		
		namestrip= re.compile("\\b&nbsp;\\b|[ 0-9\~\:\+\.\_\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
		return namestrip.sub("-",name).lower().strip("-")
	def mkblock(self):
		mkstr = "" 
		if containsAny(self.name,['the-kde-core','kde-additional-packages']):
			mkstr += "\n\n" + self.name + " : after-lfs-configuration-issues \
											 kde-pre-installation-configuration"
			
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

	
	
class Book(object):
	''' Book class to simulate book object
		link: link for online book, LFS or BLFS
		baseonbook: For BLFS only, BLFS might base on SVN LFS, or stable LFS,etc
	'''
	
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

		self.wgetlist = self.LFS.bookdir + WGETLIST
		if self.name == "BLFS":
			blfsregx.append([r"udev-lfs(-([0-9]+))+",self.udev_version])
			blfsreplace.append( ("UDEV=<version>","UDEV=%s"%self.udev_version))
			

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
		''' udev version is the same across one LFS edition, might as well decided 
			as early as possible
		'''
		if not self._udev_version :
			if self.name != "BLFS" :
				boot = self
				
			else:
				book = self.LFS
				
			pack = book.search("systemd")
			if pack:
				for p in pack:
					for cmd in p.commands:
						
						match = re.search(
						'/udev-lfs((-([0-9.]+))+)[^/]*\.tar\.((bz2)|(xz)|(gz))$',
						cmd,re.IGNORECASE)

						if match:
							self._udev_version = match.group(1).strip("-")
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
		''' Jump to specific pacakge by name,return the pacakge object '''
		soup = self.booksoup.xpath('.//a[contains(translate(., \
				"ABCDEFGHJIKLMNOPQRSTUVWXYZ", "abcdefghjiklmnopqrstuvwxyz"),"' \
				 + name.lower() + '")]/../../../h4//text()')
		
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
				self._soup = etree.HTML(open(self.link).read())
			except IOError:
				os.system("wget --recursive  --no-clobber --html-extension  \
				--convert-links --restrict-file-names=windows  \
			 	--domains www.linuxfromscratch.org   --no-parent " + self.link)
				self._soup = etree.HTML(open(self.link).read())

		return self._soup

	@property
	
	def chapters(self):
		if not self._chapters:
			print "lazy generating chapters for :",self.name
			self.listchapter(self.booksoup,".//h4")
		return self._chapters





import os,re
from util import *
from consts import *
from massRegex import *

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
wget --no-check-certificate -nc --timeout=60 --tries=5 $packlink -P ${SOURCES} || true
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
	@$(call echo_summary, ''' + \
	str(self.page.summary.replace(",","..") if self.page.summary else self.fullname) + ''')
	@$(call run_blfs_script,/etc/profile)
	@touch $@
'''		
		#@source /etc/profile && time $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
		else:
			packtgt = self.targetname + " "
			packmakeblock='''\
	@$(call echo_message, Building)
	@$(call echo_summary, ''' + \
	str(self.page.summary.replace(",","..") if self.page.summary else self.fullname) + ''')
	@$(call run_lfs_script,$(LFS))
	@touch $@
'''
	#@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
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
		#if "udev" in short:
		#		short = "systemd"
		
		if containsAny(short,['nss','json','pulseaudio','libiodbc','sax']):
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
			#print self.downloads,parselink(self.downloads[0])
			scriptstr += "preparepack \"$pkgname\" \"$version\" " + parselink(self.downloads[0])
			scriptstr += "\ncd ${SOURCES}/${pkgname}-${version} \n"
		else:
			scriptstr +=  "\ncd ${SOURCES} \n"

		scriptstr += "\n}\nbuild()\n{\n"
		if self.commands:
	
			allline = ''.join(line for i,line in enumerate(self.commands))

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
				print l,'in ignore'
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



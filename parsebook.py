#!/bin/env  python
# Version 1.04
# fix text.strip()
# Fix documentation generation dependency
# ################
# fix orderedist import 

import urllib2,os,binascii,re,sys,platform
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
try:
	from BeautifulSoup import BeautifulSoup
except ImportError:
	from bs4 import BeautifulSoup
#homedir=os.path.expanduser('~')

reload(sys) 
sys.setdefaultencoding('utf8')
homepage="http://www.linuxfromscratch.org/lfs/view/stable"
lfsloc="www.linuxfromscratch.org/lfs/view/development/index.html"
blfsloc="www.linuxfromscratch.org/blfs/view/svn/index.html"

CWD=os.path.dirname(os.path.realpath(__file__))
output=CWD + "/cmds.sh"

#lfspage=CWD + "/" + lfsloc
lfspage=CWD + "/" + lfsloc
blfspage=CWD +	"/" + blfsloc
lfslocaldir=os.path.dirname(lfspage)
blfslocaldir=os.path.dirname(blfspage)
IP="192.168.136.13"
GATEWAY="192.168.136.2"
BROADCAST="192.168.136.255"
domain="ibm.com"
nameserver1 ="192.168.136.2"
nameserver2 ="192.168.136.1"
hostname= "alfs"
guestdev1="vda1"
guestdev2="vda2"
guestfs="ext3"
guestdev="mapper/loop0"
newuser = "mao"
passwd = "ping" 
udevversion=197
hostdev1="mapper/loop0p1"
hostdev2="mapper/loop0p2"
arch=platform.machine()
if arch == 'i686':
	ABI=32
elif arch == 'x86_64':
	ABI=64
else:	
	print "Unknown platform error"
	raise 
REMOTE_HOSTNAME = "192.168.136.1"
funcstrip= re.compile("\\b&nbsp;\\b|[ \~\:\+\.\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
#chstrip= re.compile("[0-9\. ]+")
chstrip= re.compile("[0-9\.\-\/\n\t\r\(\) ]+",re.MULTILINE)
endstrip = re.compile("#.*$")
orstrip = re.compile("[ \t,\n\r]+",re.MULTILINE)

if not os.path.exists(lfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent " + lfsloc)
#soup = BeautifulSoup(urllib2.urlopen(homepage).read())
if not os.path.exists(blfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent" + blfsloc)


def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]

def replacem(str):
	if str !=None:
		return str.replace('&gt;','>').replace('&lt;','<').replace('&amp;','&')
	else:
		return 'REPLACEME'

def findchild(tag,tagname="kbd"):
	cmdline=""
	#print tag
	#global previoustagname
	#L1
	if tag.string!=None:
		tmpstr = replacem(tag.string)
		cmdline = cmdline + "\n" + tmpstr

	else:
		cmdline = cmdline + "\n"
		for code in tag.contents:
			#L2
			if code.string != None:
				cmdline = cmdline + replacem(code.string)
			else:
			
				for em in code.contents:
					#L3
					if em.string != None:
						cmdline = cmdline + replacem(em.string)
					
		cmdline = cmdline + "\n"						
	return cmdline
def lineadd(lst,block):
	if block:
		for cmdstr in block.splitlines():
			if cmdstr and cmdstr !="\n":
				#cmdstr = addtarget(cmdstr)
				lst.append(cmdstr)


def parsedependency(depsoup,link,packname):
	ps=depsoup.findAll("p",attrs={'class':re.compile(r"^(recommended|required)$")})
	if ps:
		dependstr_link="export " + packname +"_required_or_recommended=\""

		for p in ps:
			child_iter = iter(p.contents)
			for child in child_iter:
				#print child
				if  hasattr(child,"name"):
					#print child.name
					#print type(child)
					if child.has_key('href'):
						if "http://" in child['href']:
							concat = child['href']
							dependstr_link=dependstr_link + concat + " "
						else:
							
							concat = os.path.dirname(link) + "/"+ endstrip.sub("",child['href'])
						
							dependstrsoup = BeautifulSoup(open(concat).read())
							#titles=dependstrsoup.findAll("h1")
							#for title in titles:
								
								#print title.text
							#	func=title.text.strip()
							chs=dependstrsoup.findAll("div",{'class':'navheader'})
				
							for ch in chs:
								h3s=ch.findAll("h3")
								for h3 in h3s:
									#print h3.string
									chno=re.search('([0-9]{1,2})',h3.string)
							func = funcstrip.sub("_",child['title'])
							if "X_Window_System_Environment" in func:
								func = func.replace("Chapter","").replace("_","").replace("&nbsp;","").replace("24","").strip()
							try:
								dependstr_link=dependstr_link+ func  + "_C" + str(chno.group(1)) + " "
							except AttributeError:
					
								dependstr_link=dependstr_link+ func + " "
								#print dependstr_link
					
				else:
					#print "child=" + child.string
					#skip "or" entry
					orstr = orstrip.sub("",child.string)
					if orstr=="or":
						#print orstr
						#print child.string
						next(child_iter,None)
						continue
					
		dependstr_link=dependstr_link + "\"\n\n"
	else:
		dependstr_link=""
	return dependstr_link

def parsecmds(soupsub,link,func):

	#print func
	cmds=soupsub.findAll("kbd",{'class':'command'})
	
	if  cmds:
		cmdstr=func + "(){\n"
		#print cmdstr
		for cmd in cmds:
			#print cmd.string
			for p in cmd.parent.findPreviousSiblings():
				if p.findAll('a',{"title" : "BLFS Boot Scripts"}):
					cmdstr = cmdstr + '\nexec 1>&3\ntime pack_install BLFS_Boot_Scripts_C2 "/sources" || error 1  PACKBUILDFAILURE "BLFS_Boot_Scripts_C2 failed to build in $FUNCNAME"\nexec 3>&1\n'
			#print "beofre cmd"
			if cmd.parent.findPreviousSibling():
				prev = cmd.parent.findPreviousSibling().text.encode('utf-8').strip()
				#if containsAny(prev, ['doxygen','Doxygen','documentation','texlive']):
				#	print prev
				if containsAny(prev, ['doxygen','Doxygen','texlive','TeX Live','Sphinx']) and not containsAny(prev,['Install Doxygen']):
					#print "------------------1-------------------------"
					#print prev
					#print cmd
					childcmd = ""
				elif   containsAny(prev, ['documentation','manual']) and containsAny(prev, ['If you','API','alternate''optional','Sphinx','DocBook-utils','Additional']) and  not containsAny(prev,['If you downloaded','Man and info reader programs','The Info documentation system']):
					#print "------------------2-------------------------"
					#print prev
					#print cmd
					childcmd = ""
				else:
					
					childcmd = findchild(cmd) # cmd.text.encode('utf-8').strip() + "\n" #
		
			cmdstr = cmdstr + childcmd
		cmdstr = cmdstr + "\n}\n\n"
	else:
		cmdstr =""
	return cmdstr

def parsedownload(soupsub,link,func):

		uls=soupsub.findAll("ul",attrs={'class':'compact'})
		counter=0
		doOnce=0
		if uls:
			download_link="export " + func.strip() +"_download=\""
			full_package_name="export " + func.strip() +"_packname=\""
			for ul in uls:
				for alink in ul.findAll("a",attrs={'class':'ulink'}):
					#print alink['href']
					if str(alink['href']).endswith('/') or "certdata" in str(alink['href']):
						download_link = download_link + " "  
					else:
						if doOnce==0:
							mat = re.search('/([^/]+)$',alink['href'])
							full_package_name= full_package_name + mat.group(1)
							doOnce = 1
						download_link = download_link + alink['href'] + " "
					 
			download_link = download_link + "\"\n\n"
			full_package_name = full_package_name + "\"\n\n"  
		else:
			download_link=""
			full_package_name =""
			
		download_link =  download_link + full_package_name
		return download_link
def parsesect(soup):

	#cmds=soup.findAll(attrs={'class':re.compile(r"^(userinput|root)$")})
	level=0
	for i in range(5):
	
		title=soup.findAll('h'+ str(i+1),attrs={'class':'sect'+str(i+1)})
		#print "title===",title
		if title:
			for ah in title:
				if level == 0:
					for a in ah.findNextSiblings():
						#if a.has_key('class'):
							#print 'class=====',a['class']
							#print type(a['class'])
							#print ('root' in a['class'])
							#print ('userinput' in a['class'])
						if a.has_key('class') and ( 'root' in a['class'] or 'userinput' in a['class'] ):
							#print a['class']
							#print "i===",i
							level = i
							#print "level===",level
							break
				else:	
					break
		else:
			break
	return level

def parsepage(link,func,chapternum):
		
		packstr = func.strip()
		#print packstr

		soupsub = BeautifulSoup(open(link).read())
		level = parsesect(soupsub)
		#print level 
		func=""
		if level > 1:
			titles=soupsub.findAll('h'+ str(level),attrs={'class':'sect'+str(level)})
		
			for i in range(len(titles)):
				sect = titles[i].parent
				#print len(sect)
				subfunc = funcstrip.sub("_",titles[i].text.strip()) + "_C" + chapternum
				func+= parsecmds(sect,link,subfunc)

				func+=parsedownload(sect,link,subfunc)

				func+=parsedependency(sect,link,subfunc)
		else:
			func+= parsecmds(soupsub,link,packstr)

			func+=parsedownload(soupsub,link,packstr)

			func+=parsedependency(soupsub,link,packstr)
			
		
		return func	

def parseexternal(link,func):
	soup = BeautifulSoup(urllib2.urlopen(link).read())
	
	alink = soup.findAll("a",attrs={'href':re.compile("tar\.gz")}) # package link
	
	if alink:
		match = re.search('(http://[^/]+/)',link) #http://search.cpan.org/
		download_link="\n\nexport " + func.strip() + "_C13" + "_download=\"" +match.group(1) +  alink[0]['href'].strip("/") + "\"\n"
		mat = re.search('/([^/]+)$',alink[0]['href'])
		
		full_package_name="export " + func.strip() + "_C13" + "_packname=\"" +  mat.group(1) + "\"\n\n"
		return download_link + full_package_name
	else:
		return ""

def parseperldownload(alink,link,func):
	
	if alink and alink.has_key('href'):
		
		if str(alink['href']).endswith('/'): #parse external link :http://search.cpan.org/~gaas/LWP-Protocol-https/
			
			download_link = str(parseexternal(str(alink['href']),func))
			full_package_name = ""
		elif   ".html#" in str(alink['href']):# same page no need to parse,ex:# /www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
			download_link =""
			full_package_name =""
		elif ".html" in str(alink['href']): #within BLFS, no need to parse
			
			download_link =""
			full_package_name =""
		else:                               # otherwises, need to parse all 
			download_link="export " + func.strip() + "_C13" +"_download=\""
			full_package_name="export " + func.strip() + "_C13" +"_packname=\""
			try:
				mat = re.search('/([^/]+)$',alink['href'])
				full_package_name= full_package_name + mat.group(1)
			except AttributeError:
				full_package_name= full_package_name + " "
			
			download_link = download_link + alink['href'] + " "
			download_link = download_link + "\"\n\n"
			full_package_name = full_package_name + "\"\n\n"  
	else:
		download_link =""
		full_package_name =""
 
	download_link =  download_link + full_package_name
	return download_link


def parsewithinproject(alink,link):
	
	inside_link=""
	if alink.has_key('href'):

		
		concat = os.path.dirname(link) + "/"+ endstrip.sub("",alink['href'])

		dependstrsoup = BeautifulSoup(open(concat).read())
		titles=dependstrsoup.findAll("h1")
		for title in titles:
		
			func=title.text.strip()
		chs=dependstrsoup.findAll("div",{'class':'navheader'})

		for ch in chs:
			h3s=ch.findAll("h3")
			for h3 in h3s:
				
				chno=re.search('([0-9]{1,2})',h3.string)
		try:
			inside_link += funcstrip.sub("_",func)  + "_C" + str(chno.group(1)) + " "
		except AttributeError:

			inside_link+= funcstrip.sub("_",func) + " "
				
		return inside_link


def perldepend(div,link,func):
	
	if div.string == None:
		for ul in div.contents:
			 if ul.string == None:
				#print ul
				reqlink=""
				function=""
				downlink=""
				if func:
					reqlink = func  + "_C13" + "_required_or_recommended=\""
					
				for li in ul.contents:   # Iterate over lis
					
					if li.string == None:
						try:
							url = str(li.a['href'])
						except (KeyError,AttributeError):
							li.a = li.a.findNextSibling(attrs={'class':'ulink'})
							url = str(li.a['href'])
							
						if func and ".html#" in url: # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
							
							reqlink += funcstrip.sub("_",li.a.text.strip()) + "  "

						elif func and ".html" in url: # /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/postlfs/openssl.html
							
							reqlink += parsewithinproject(li.a,link) + "  "

						elif func :  # http://search.cpan.org/~gaas/LWP-Protocol-https/
							reqlink += funcstrip.sub("_",li.a.text.strip()) + "  "
							function += funcstrip.sub("_",li.a.text.strip()) + "_C13" + "(){ \nperl Makefile.PL &&\nmake &&\nmake install\n}\n"
							downlink += parseperldownload(li.a,"",funcstrip.sub("_",li.a.text.strip()))
						else:        #http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz/ TITLE
							
							function += funcstrip.sub("_",li.a.text.strip()) + "_C13" + "(){ \nperl Makefile.PL &&\nmake &&\nmake install\n}\n"
							downlink += parseperldownload(li.a,"",funcstrip.sub("_",li.a.text.strip()))
				if func:
					reqlink += "\"\n"
				
				dependstr = reqlink + downlink + function
				
				for li in ul.contents:  # Iterate over div of class itemizedlist
					if li.string == None and li.div:
						# Tiltle of next div need to be iterate, for example, Crypt::SSLeay-0.64
						func = funcstrip.sub("_",li.div.findPreviousSibling().a.text.strip())
						dependstr += perldepend(li.div,link,func)

		return dependstr
						

def parseperl(link):
	soup = BeautifulSoup(open(link).read())
	titles=soup.findAll('h3')
	
	perlstr=""
	for title in titles:
		func = funcstrip.sub("_",title.text.strip())
		#print title.text.encode('utf-8').strip()
		print "Parseing: ",func.encode('utf-8').strip()
		while title != None:
			title = title.findNextSibling(attrs={'class':'itemizedlist'})

			if title != None :#and #func == "Crypt_SSLeay_0_64" :
				#print title
				 perlstr += perldepend(title,link,"")
			break
	return perlstr	

def parseindex(index,file):
	match = re.search('/([a-z]*lfs)/',index)
	try:
		book = match.group(2).upper()
	except AttributeError:
		book = ""
	soup = BeautifulSoup(open(index).read())
	chapters ="export " + book + "CHAPTERS=\""
	chapter =""
	
	file.write("BLFS_Boot_Scripts_C2(){\n: \n} \n\n")
	titles=soup.findAll("h4")
	counter=0
	#print titles
	for title in titles:
		
		cha = chstrip.sub("",title.text.strip())
		chapters = chapters + "C" + str(counter) + "_" + cha + " "
		
	
		chapter="export " + "C" + str(counter) + "_" +  cha + "=\""
		uls=title.findNextSiblings()
		for ul in uls:
			links= ul.findAll("a")
		
			for link in links:	
				func =  funcstrip.sub("_",link.string) + "_C" + str(counter)
				print "Parseing: ",func
	
				chapter=chapter + func + " "
	
				if link.has_key('href'):
					#print link['href']
					sublink=os.path.dirname(index) + "/"+link['href']
					#print sublink
					#if "Wget" in func or "OpenSSH" in func or "OpenSSL" in func or "BLFS_Boot" in func:
					
					if "Perl_Modules" in func:
						file.write(parseperl(sublink))
					else:
					#elif "D_Bus" in func:	
						file.write(parsepage(sublink,func,str(counter)))
					


			chapter = chapter + "\"\n"
			
			if "XWindowSystemEnvironment" in cha:
				chapter=chapter +  cha + "(){\nexec 1>&3\n"
				for link in links:
					func =  funcstrip.sub("_",link.string) + "_C" + str(counter)
					chapter=chapter + "time pack_install " + func + '  "/sources"' + "\n"
				chapter = chapter + "\nexec 3>&1\n}\n"

			file.write(chapter + "\n\n")
			
		counter = counter + 1

	file.write(chapters+"\"\n")

globalreplace = [
		('&gt;',						'>'),
		('&lt;',						'<'),
		('&amp;',						'&'),
		("IP=192.168.1.1",					"IP="+IP),
		("GATEWAY=192.168.1.2",					"GATEWAY=" + GATEWAY),
		("BROADCAST=192.168.1.255",				"BROADCAST=" + BROADCAST),
		("domain <Your Domain Name>",				"domain " + domain),
		("nameserver <IP address of your primary nameserver>",	"nameserver " + nameserver1),
		("nameserver <IP address of your secondary nameserver>","nameserver " + nameserver2),
		("127.0.0.1 <HOSTNAME.example.org> <HOSTNAME> localhost","127.0.0.1 localhost\n" + IP + "	alfs"),
		('echo "HOSTNAME=<lfs>" > /etc/sysconfig/network',	'echo "HOSTNAME=' + hostname + '" > /etc/sysconfig/network'),
		('KEYMAP="de-latin1"',					'KEYMAP="us"'),
		('KEYMAP_CORRECTIONS="euro2"',				''),
		('LEGACY_CHARSET="iso-8859-15"',			''),
		('FONT="LatArCyrHeb-16 -m 8859-15"',			''),
		('/dev/<xxx>     /            <fff>    ',		'/dev/' + guestdev1 + '     /            ' + guestfs + '    '),
		('/dev/<yyy>     swap         swap     ',		'/dev/' + guestdev2 + '    swap         swap     '),
		("zoneinfo/<xxx>",					"zoneinfo/Asia/Shanghai"),
		("PAGE=<paper_size>",					"PAGE=A4"),
		("chown -v",						"chown -Rv"),
		("export LANG=<ll>_<CC>.<charmap><@modifiers>",	"export LANG=en_US.utf8"),
		('DISTRIB_CODENAME="<your name here>"',			'DISTRIB_CODENAME="MAO"'),
		("passwd lfs",						"echo 'lfs:ping' | chpasswd"),
		("passwd root",					"echo 'root:ping' | chpasswd"),
		("make test",						""),
		("exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash",		"source ~/.bashrc"),
		("set root=(hd0,2)",					"set root=(hd0,1)"),
		("root=/dev/sda2 ro",					"root=/dev/" + guestdev1 + " ro"),
		("./configure --prefix=/usr --enable-cxx",		"ABI=" + str(ABI) +" \n./configure --prefix=/usr --enable-cxx"),
		("--with-libpam=no",					""),
		("./configure --sysconfdir=/etc",			"./configure --sysconfdir=/etc --with-libpam=no"),
		("make LANG=<host_LANG_value> LC_ALL= menuconfig",	'yes "" | make oldconfig'),
		("mkdir -v",						"mkdir -pv"),
		("mkdir /",						"mkdir -pv /"),
		("grub-install /dev/sda",				"grub-install /dev/" + guestdev ),
		("mount -v -t ext3 /dev/<xxx> $LFS",			'mount -v -t ext3 /dev/' + hostdev1 + ' $LFS'),
		("/sbin/swapon -v /dev/<zzz>",				"/sbin/swapon -v /dev/" + hostdev2),
		("build/udevadm hwdb --update", 			"sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh\nbuild/udevadm hwdb --update"),
		("bash udev-lfs-197-2/init-net-rules.sh",		'bash udev-lfs-197-2/init-net-rules.sh\nsed -i "s/\\"00:0c:29:[^\\".]*\\"/\\"00:0c:29:*:*:*\\"/" /etc/udev/rules.d/70-persistent-net.rules'),
		("useradd -m <newuser>",				'useradd -m ' + newuser),
		("<username>",						newuser),
		("<password>",						passwd),
		('export PATH="$PATH',					'export PATH=$PATH'),
		('<PREFIX>',						'/opt'),
		('dhclient <eth0>',					'dhclient eth0'),
		('--docdir=/usr/share/doc/<udev-Installed LFS Version> &&', '--docdir=/usr/share/doc/' + str(udevversion) + ' &&'),
		(' /etc/openldap/schema                 &&',		' /etc/openldap/schema'),
		('mysqladmin -u root password <new-password>',		'mysqladmin -u root password ' + passwd),
		(' $DOCNAME.dvi  &&',					' $DOCNAME.dvi'),
		('"EOF" &&',						'"EOF"'),
		('REMOTE_HOSTNAME',					REMOTE_HOSTNAME),
		('cat > /etc/pam.d/sudo << "EOF"',			'mkdir -pv /etc/pam.d/\ncat > /etc/pam.d/sudo << "EOF"'),
		('install -v -dm755 /usr/share/doc/libassuan-2.1.0 &&',  'install -v -dm755 /usr/share/doc/libassuan-2.1.0'),
		('                    /usr/share/doc/libgcrypt-1.5.1 &&','                    /usr/share/doc/libgcrypt-1.5.1'),
		('mkdir build',						'mkdir -pv build'),
		('mkdir xc',						'mkdir -pv xc'),
		('mkdir proto',					'mkdir -pv proto'),
		('mkdir lib',						'mkdir -pv lib'),
		('mkdir app',						'mkdir -pv app'),
		('mkdir font',						'mkdir -pv font'),
		('mkdir ../',						'mkdir -pv ../'),
		('docbook_dsssl_1_79_C44 Itstool_1_2_0_C45',		''),
		('GLib_2_34_3_C9 Intltool_0_50_2_C11 SpiderMonkey_1_0_0_C11 ','GLib_2_34_3_C9 Intltool_0_50_2_C11 SpiderMonkey_1_0_0_C11 docbook_dsssl_1_79_C44 Itstool_1_2_0_C45'),
		('cat > /etc/pam.d/polkit-1 << "EOF"',			'mkdir -pv /etc/pam.d/\ncat > /etc/pam.d/polkit-1 << "EOF"'),
		('cd src &&',						'tar xvf krb5-1.11.2.tar.gz\ncd krb5-1.11.2\ncd src &&'),
		('--with-gif=no',					''),
		('            --localstatedir=/var &&',		'            --localstatedir=/var --with-gif=no &&')
		
]


def massreplaceline(string):
	for k, v in OrderedDict(globalreplace).iteritems():
		#print "from: ",k,"to: ",v
		#if "make LANG=<host_LANG_value>" in string and "host_LANG_value" in k:
		if k in string:
			print "Replacing :",k," with :",v,"\n"
		#print string
   			string = string.replace(k, v)
		#if "grub/grub.cfg" in string:

		#print string
	return string




deleteblock = [ ("Entering_the_Chroot_Environment_C6(){",			"}"),
	  	("pushd testsuite",						"popd"),
		("Cleaning_Up_C6(){",						"}"),
		("Typography_C0(){",						"}"),
		("About_SBUs_C4(){",						"}"),
		("Package_Management_C6(){",					"}"),
		("Conventions_Used_in_this_Book_C1(){",				"}"),
		("Notes_on_Building_Software_C2(){",				"}"),
		("About_LFS_C4(){",						"}"),
		("General_Compilation_Instructions_C5(){",			"}"),
		("Rebooting_the_System_C9(){",					"}"),
		("Creating_a_File_System_on_the_Partition_C2(){",		"}"),
		("Conventions_Used_in_this_Book_C1(){",				"}"),
		("Notes_on_Building_Software_C2(){",				"}"),
		("cat > /etc/krb5.conf << \"EOF\"",        			"make install-krb5"),
		("Running_a_CVS_Server_C13(){",					"}"),
		("Perl_Modules_C13(){",						"}"),
		("kdb5_util create -r <LFS.ORG> -s",				"ktutil: l"),
		("Host_System_Requirements_C0(){",				"}"),
		("Locale_Related_Issues_C2(){",					"}"),
		("About_Devices_C3(){",						"}"),
		("About_RAID_C5(){",						"}"),
		("twadmin --create-polfile --site-keyfile /etc/tripwire/site.key \\", "twadmin --create-polfile /etc/tripwire/twpol.txt &&"),
		("mkinitramfs [KERNEL VERSION]",				"  linux  /vmlinuz-3.2.6-lfs71-120220 root=LABEL=lfs71 ro"),
		("  initrd /initrd.img-3.2.6-lfs71-120220",			"}"),
		('make distclean &&',						'make distclean'),
		("6_3_2_Package_Management_Techniques_C6(){",			"}"),
		("qemu-img create -f qcow2 vdisk.img 10G",			"qemu -enable-kvm vdisk.img -m 384"),
		("Xorg_7_7_Testing_and_Configuration_C24(){",			"}")

		
	]

def rmblock(path,block):
	lines = open(path).readlines()
	#for a in lines:
	#	print a
	for k, v in OrderedDict(block).iteritems():
		
		try:                     
			blockstart = lines.index(k  + "\n")  
		except (ValueError,TypeError) as e:
			blockstart = ""
		try:
			blockend = lines.index(v + "\n",blockstart)
			
		except (ValueError,TypeError) as e:
			blockend = ""
		#print blockstart,blockend
		if blockend and blockstart:
			print "Removing Block:",k,v," between ",blockstart," and ",blockend
			del(lines[blockstart:blockend+1])  
		#return lines  
	#print "-------------------------------------"
	#for a in lines:
	#	print a           
	open(path, 'w+').writelines(lines)  

ignorelist = ['dummy',
	'libfoo',
	'make check',
	'localedef',
	'tzselect',
	'spawn ls',
	'ulimit',
	':options',
	'logout\n',
	'exit\n',
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
	'export LIBRARY_PATH=/opt/xorg/lib'
	]
def massreplaceall(fileobj):
	
	#lines = open(fileobj)
	#print type(lines)
	retlines= []

	for i,line in enumerate(open(fileobj)):
		#print line
		if  containsAny(line,ignorelist):
			print "Delete line:",i,":",line
			pass
   		else:
			#print line
			line = massreplaceline(line)
			#print line
			retlines.append(line)
			 # sys.stdout is redirected to the file
	open(fileobj, 'w+').writelines(retlines)  
			#sys.stdout.write(line)

def parseandwrite():
	file = open(output, 'wb')
	file.write("#!/bin/bash\n")
	parseindex(lfspage,file)
	#parseindex(blfspage,file)
	file.close

if  os.path.exists(output):
	var = raw_input(output + " already existed, regenerate?[y/n]: ")
	if 'y' in var or 'Y' in var:
		parseandwrite()
	elif 'n' in var or 'N' in var:
		pass
	else:
		print "Invalid Input, exit"
		sys.exit(1)
else:
	parseandwrite()
massreplaceall(output)
rmblock(output,deleteblock)




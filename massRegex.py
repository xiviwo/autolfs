
import re
from consts import *

def matchgroupuser(lines,line,pre):
	"""Match group|user adding or moding block from command line"""
	if re.search('groupadd|usermod|useradd',line):
			line = line.strip().strip("&&")
			
			if re.search('useradd',line) and line.endswith('\\'):
				
				pre.append(line + " || : ")
				pre.append(next(lines))
				return 1
				 
			else:
				pre.append(line + " || :\n")
				return 1
	else:
		
		return 0

def matchBlock(start,end,lines,line,lst,cont=True,repl=True):
	"""Match block from 'start' to 'end' """
	if re.search(start,line,re.MULTILINE):
		#InstallRegx(InstallSpaceFolder,SpaceFolder)
		if repl : line =  InstallRegx(InstallSubRegex,make_dummy).sub(line)
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
def getlistname(lst):
	tmp = []
	tmp = globals()
	for k,v in tmp.items():
		
		if v == lst :
		
			return k
		
class Singleton(type):
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        
	else:
            cls._instances[cls].__init__(*args, **kwargs)
	return cls._instances[cls]
 

class MultiRegex(object):
	"""multiple regex match at the same time, performance boost. """
	__metaclass__ = Singleton
	flags = re.I #re.MULTILINE
	regexes = ()

	def Block(self,mo,*args):

		if isinstance(mo, type(re.match("",""))):
			print "found match 1 = ", mo.group()
			print mo.groupdict()
			return mo.group()
		for arg in args:
			if isinstance(arg, type(re.match("",""))):
				print "found match 2= ", arg.group()
				return arg.group()
		
	
	def __init__(self,regex,func):
		"""
		compile a disjunction of regexes, in order
		"""

		regname =  str(id(regex))

		funcname = func.__name__ 

		try:
			self._regx = getattr(self, regname)
		except AttributeError:


			try:

				if type(regex[0]) is str:
					regx = "(?P<" + funcname + '>(' + '|'.join(l for l in regex) + '))'

					ex = "|" + regx if self.regexes  else regx
			
					regvalue = re.compile( "|".join(self.regexes) + ex, self.flags)
				else:
					regx = '|'.join("(?P<" + str('replace_line' if funcname == "make_dummy" else funcname) 
									+ str(i) + '>' + l + ")" for i,l in enumerate(zip(*regex)[0]))
					ex = "|" + regx if self.regexes  else regx
					
					regvalue = re.compile("|".join(self.regexes) +  ex , self.flags)
	

			except IndexError:
				raise Exception('Regex {0} list is Null'.format(regx))


			setattr(self, regname,regvalue)
			self._regx = getattr(self, regname)


			if callable(func):

			
				__method = func(self,regex)

				if callable(__method):
					setattr(self, funcname, __method)
				else:
					setattr(self, funcname, func)

	def findmatch(self,s,*args):
		for mo in self._regx.finditer(s):
			
			print

			for k,v in mo.groupdict().iteritems():

				if v:
					
					func = getattr(self, k)


					if callable(func):
						
						return func(self,mo,*args)
						break
					else:
	
						return func
						break
		return ''
	
	def search(self,s,*args):
		'''
		Similar to regex search
		'''
		c=0
		for mo in self._regx.finditer(s):

			print

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
		'''
		mimic regex substitle
		'''
		return self._regx.sub(self._sub, s)
    	
	def _sub(self, mo,*args):
		'''
		determine which partial regex matched, and
		dispatch on self accordingly.
		'''

		#print mo.groupdict()

		for k,v in mo.groupdict().iteritems():
		    
		    if v:
			

		        sub = getattr(self, k)
		        if callable(sub):

		            return sub(self,mo,*args)
		        return sub
		raise AttributeError,'nothing captured, matching sub-regex could not be identified'




BuildSubRegex = (
(r'patch -Np1 -i ../',		'patch -Np1 -i %_sourcedir/'),
(r'f \.\./',			"f  %_sourcedir/"),
(r'(d \.\./)',		"d  %_sourcedir/"),
)

BuildCDRegex =(
r'^cd [^|]*',
)

BuildPreRegex =(
r'^\s*install.*',
r'^\s*chown.*',
r'^\s*chgrp.*',
)

BuildMakeRegex=(
r'(.*(?<![a-z])make[\n ].*)',		

)



def make_dummy(self,regx):
  

	for i,v in enumerate(regx): 
		name = "replace_line" + str(i)

		if callable(replace_line):
			_method = replace_line(self,i,regx)
			setattr(self, name, _method)
    

def append_line(self,regx):
    def _method(self,*args):
	for arg in args:
		if isinstance(arg, type(re.match("",""))):

			return arg.string.strip("\n").strip() + ' %{?_smp_mflags} \n'
    return _method

def replace_line(self,i,regx):
    def _method(self,*args):
	
	for arg in args:
		
		if isinstance(arg, type(re.match("",""))):
			line = arg.string
			
			org= str(arg.group())
			
			return re.sub(regx[i][0],regx[i][1],org)
    return _method

def move_line(self,mo,*args):
	def _method(self,*args):

		for arg in args:
			if isinstance(arg, type(re.match("",""))):
				line = arg.string
		for arg in args:

			if type(arg) is list:

				arg.append(line)

				break
	return _method
def return_line(self,mo,*args):
	
	if isinstance(mo, type(re.match("",""))):

		return mo.group()

	for arg in args:
		if isinstance(arg, type(re.match("",""))):

			return arg.group()
	return ''

def return_block_tag(self,mo,*args):
	return "TOBEREPLACED"

def skip_line(self,regx):
	return ''

BuildArg = (
(BuildSubRegex,make_dummy),
(BuildCDRegex,move_line),
(BuildPreRegex,move_line),
(BuildMakeRegex,append_line),
)
def Make(self,mo,*args):

	for arg in args:
		
		if isinstance(arg, type(re.match("",""))):
			line = arg.string
			break

	return line.replace("&&","").strip() + ' %{?_smp_mflags} \n'

class BuildRegx(MultiRegex):
	regexes = (

	)





def parsebuild(build,buildfolder,pre):
	tmp = build
	build = []

	lines = iter(tmp)
	for i,line in enumerate(lines):
		
	 	
		if matchgroupuser(lines,line,pre): continue	
		if matchBlock('cat (>|>>)\s*/.*(EOF|"EOF")','^EOF',lines,line,build,True,False) : continue
		
		if BuildRegx(BuildPreRegex,move_line).search(line,pre) : continue
		#print dir(BuildRegx),'ppppppppppppppppppp'
		BuildRegx(BuildCDRegex,move_line).search(line,buildfolder)
		
		line = BuildRegx(BuildSubRegex,make_dummy).sub(line)
		
		line = BuildRegx(BuildMakeRegex,append_line).sub(line)

		build.append(line)
	
	return build

InstallSubRegex = (
(r'=/',			"=${RPM_BUILD_ROOT}/"),
(r'DESTDIR=',		"DESTDIR=${RPM_BUILD_ROOT}"),
(r'(f \.\./)',		"f  %_sourcedir/"),
(r'(d \.\./)',		"d  %_sourcedir/"),

)





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


	
InstallArg = (
(InstallSubRegex,make_dummy),
(PostrunRegex,move_line),
#(InstallSpaceFolder,SpaceFolder),
#(InstallMakeInstall,MakeInstall),
)
def SpaceFolder(self,mo,*args):

	if isinstance(mo, type(re.match("",""))):
		line = mo.string
	else:
		line = ""
	for arg in args:
		#print 'arg===',arg
		if isinstance(arg, type(re.match("",""))):
			line = arg.string
		
			break

	#line = args[0].string

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

			pass
		line = line[:8].replace(' /',' ../') + line[8:].replace(' /'," ${RPM_BUILD_ROOT}/")

	else:
		return line.replace(' /'," ${RPM_BUILD_ROOT}/")

	 	
	return line



def MakeInstall(self,mo,*args):
	if isinstance(mo, type(re.match("",""))):
		line = mo.string
	else:
		line = ""
	for arg in args:

		if isinstance(arg, type(re.match("",""))):
			line = arg.string
			break

	if "make modules_install" in line:
		line = line.strip("\n") + " INSTALL_MOD_PATH=${RPM_BUILD_ROOT} \n"
	if "make BINDIR=${RPM_BUILD_ROOT}/sbin install" in line: 

		line = line.strip("\n") + " install prefix=${RPM_BUILD_ROOT} \n"
	if "make -C src install" in line:

		line = line.strip("\n") + " ROOT=${RPM_BUILD_ROOT} \n"
	if "&&" in line:

		line = line.strip("\n").strip() + " DESTDIR=${RPM_BUILD_ROOT} \n"
	else:
		line = line.strip("\n") + " DESTDIR=${RPM_BUILD_ROOT} \n"
	#print "line ====",line
	return line
class InstallRegx(MultiRegex):
	regexes = (
	
	)



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
			if matchBlock('cat >>\s*/.*(EOF|"EOF")','^EOF',lines,line,postrun,True,False): 
				continue
			if matchBlock('cat >\s*/.*(EOF|"EOF")','^EOF',lines,line,install): 
				continue
			if matchBlock('cat (>|>>) ~/','^EOF',lines,line,postrun) : 
				continue
			if matchBlock('^menuentry ','^}',lines,line,trash) : 
				continue
			#if matchPostAction(line,postrun) : continue 
			#if matchUserSettings(line,postrun) : continue 
			#if matchChangeGroupUser(line,postrun): continue
			if InstallRegx(PostrunRegex,move_line).search(line,postrun): 
				continue
			line = InstallRegx(InstallSubRegex,make_dummy).sub(line)
			line = InstallRegx(InstallSpaceFolder,SpaceFolder).sub(line)
			line = InstallRegx(InstallMakeInstall,MakeInstall).sub(line)

			if containsAny(line, ['bash udev-lfs-206-1/init-net-rules.sh']):
				install.append("mkdir -pv ${RPM_BUILD_ROOT}/etc/udev/rules.d/\n")
				install.append("cp -v /etc/udev/rules.d/70-persistent-net.rules \
								${RPM_BUILD_ROOT}/etc/udev/rules.d/\n")
				install.append('sed -i \'s/\"00:0c:29:[^\\".]*\"/\"00:0c:29:*:*:*\"/\' \
                               ${RPM_BUILD_ROOT}/etc/udev/rules.d/70-persistent-net.rules\n')
				continue

		install.append(line)
			

	return install
SkipBlock = r'(?P<Block>(EOF|"EOF")((?!EOF).)*EOF)'

DeleteBlock = (
r'menuentry.*}',

)
class BookRegex(MultiRegex):
	#regexes = (SkipBlock,)
	pass

class BookReplace(MultiRegex):
	#regexes = (SkipBlock,)
	pass
class BookIgnore(MultiRegex):
	pass


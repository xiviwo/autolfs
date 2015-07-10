
import re

def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]

def run_once(f):
	"""Make sure one specific function run only once for each instance """
	def wrapper(*args, **kwargs):
		if not wrapper.has_run:
			wrapper.has_run = True
			return f(*args, **kwargs)
	wrapper.has_run = False
	return wrapper

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
		# changed in 7.6, /([-.\w]*[^/]*\.*(tar)*\.*((zip)|(tar)|(bz2)|(xz)|(gz)|(tgz)|(pm))+$)
		packmat = re.search("/([^/]*)$",download_link.strip())
	
		try:
			packname = packmat.group(1).strip()
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


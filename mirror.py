
import urllib2,os
from lxml import etree
from consts import *
from util import *


class DownMirror:
	def __init__(self,mfile):
		self.history=[baselink]
		self.mirrorfile = open(mfile,'ab+')
		self.filestr = self.mirrorfile.read()


	def download(self,baseMirrorLink,bookversion):
		mirrorlink = re.search("/" + bookversion + "/",self.filestr,re.MULTILINE)
		if not mirrorlink:
			link = baseMirrorLink + bookversion + "/"
			soup = etree.HTML(urllib2.urlopen(link).read())

			alinks = soup.xpath(".//a/@href")
			for a in alinks:
				if "http://" in a:
					nlink = a
				else:
					nlink = link + a
				if nlink.endswith("/") and nlink not in self.history:
				
					self.history.append(nlink)
					self.download(nlink)
				elif not nlink.endswith("/")  and nlink not in self.history:	
				
					if nlink not in self.filestr:
						self.mirrorfile.write(nlink+"\n")
				else:	
					pass
	def search(self,link):
		mirrormat = re.search("/([^/]*)$",link).group(1)
		
		mlink = re.search("^(.*" + re.escape(mirrormat) + ")$",self.filestr,re.MULTILINE)
		
		if mlink:
			
			return mlink.group(1)
		else:
			return None


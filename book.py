#!/usr/bin/env python
import re,os
from chapter import Chapter
from lxml import etree
from settings import *
from consts import *
from util import *


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

		self.wgetlist = self.LFS.bookdir + "/wget-list"
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
		print name,':Found ',len(soup),' entries'
		if soup:
			for a in soup:
				
				txt= a.strip()
				if txt is not None:
					chapters.append(txt)
			#print 'ch=',chapters
			for chapter in chapters:
				
				mat= re.search("^\s*([0-9]{1,2})",chapter)
				if mat:

					chnos.append(int(mat.group(1))) 
			#print chnos
			for chno in chnos:
				#print '---',chnos
				dchapter = self.findchapter(chno)
				
				if dchapter:
					for i,page in enumerate(dchapter.pages):
						print i,name.lower(),NormName(page.name).replace("-"," ")
						if re.search(name.lower(),NormName(page.name).replace("-"," "),re.MULTILINE):
					
							counter= i
							
							#break
				
							for pack in dchapter.pages[i].packages:
								##print '==',pack
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



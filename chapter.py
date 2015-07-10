#!/usr/bin/env python
import re,os
from page import Page
from util import *

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
			mkstr += "\n\n" + self.name + " : after-lfs-configuration-issues kde-pre-installation-configuration"

		elif self.name not in "after-lfs-configuration-issues" and self.name not in "important-information":
			mkstr += "\n\n" + self.name + " : version_info important-information after-lfs-configuration-issues "
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


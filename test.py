import re
from book import Book
from chapter import Chapter
from page import Page
from package import Package
from util import *
from lxml import etree
from collections import deque
import urllib2
from consts import *

perlcmd= ['perl Makefile.PL && make && make install\n']


link = "www.linuxfromscratch.org/blfs/view/stable/index.html"
link2 = "www.linuxfromscratch.org/lfs/view/stable/index.html"

LFS=""
SOURCES=LFS + '/sources'

blfs = Book(link, Book("www.linuxfromscratch.org/lfs/view/stable/index.html"))
pp =  blfs.search("alsa")#perl modules") 
print len(pp)
print ' '.join(p.fullname.strip() if p.fullname.strip().startswith('alsa') else '' for p in pp)
for p in pp:
	print p.name#,p.dependency

#pp =  blfs.search("oss")
 
#for p in pp:
#	print p.fullname,p.dependency,p.shortname,p.version
#lfs = Book(link2)
#e = lfs.search("eudev")[0]
#print e.name,e.downloads

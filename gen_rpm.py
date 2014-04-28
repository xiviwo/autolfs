#!/usr/bin/env python
# Purse: TO automactically generate specs file for building rpm package.
# Usage: gen_rpm.py lfs/blfs
#1.0

from lfs import Book,Chapter,Page,Package
import os,sys

book = ['lfs','blfs']
my = os.path.basename(__file__)
def Usage():
	print("Usage: %s lfs/blfs "%my)
	sys.exit(1)

if len(sys.argv) != 2  :
	print("To generate specs file for blfs or lfs")
	Usage()
elif sys.argv[1].lower() not in book:
	print "Expecting lfs or blfs as target"
	Usage()

link = "www.linuxfromscratch.org/lfs/view/stable/index.html"
link2 = "www.linuxfromscratch.org/blfs/view/stable/index.html"
lfs = Book(link)
blfs = Book(link2,lfs)
target = None

if sys.argv[1].lower() == book[0]:
	target = lfs
else:
	target = blfs

for chapter in   target.chapters:
	
	for page in chapter.pages:
		
		for pack in page.packages:
			print pack.name
			pack.writespecs()

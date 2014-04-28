#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=docbook-utils
version=0.6.14
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/docbook-utils-0.6.14-grep_fix-1.patch
nwget ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/docbook-utils-0.6.14.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" docbook-utils-0.6.14.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../docbook-utils-0.6.14-grep_fix-1.patch 
sed -i 's:/html::' doc/HTML/Makefile.in                

./configure --prefix=/usr --mandir=/usr/share/man      
make

make docdir=/usr/share/doc install

for doctype in html ps dvi man pdf rtf tex texi txt
do
    ln -svf docbook2$doctype /usr/bin/db2$doctype
done


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

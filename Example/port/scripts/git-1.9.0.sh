#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=git
version=1.9.0
export MAKEFLAGS='-j 4'
download()
{
nwget https://www.kernel.org/pub/software/scm/git/git-manpages-1.9.0.tar.xz
nwget https://www.kernel.org/pub/software/scm/git/git-1.9.0.tar.xz
nwget https://www.kernel.org/pub/software/scm/git/git-htmldocs-1.9.0.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" git-1.9.0.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-gitconfig=/etc/gitconfig 
make

make html

make man

make install

make install-man

make htmldir=/usr/share/doc/git-1.9.0 install-html              
mkdir -pv -p /usr/share/doc/git-1.9.0/man-pages/{html,text}         
mv       /usr/share/doc/git-1.9.0/{git*.txt,man-pages/text}     
mv       /usr/share/doc/git-1.9.0/{git*.,index.,man-pages/}html 
mkdir -pv /usr/share/doc/git-1.9.0/technical/{html,text}         
mv       /usr/share/doc/git-1.9.0/technical/{*.txt,text}        
mv       /usr/share/doc/git-1.9.0/technical/{*.,}html           
mkdir -pv /usr/share/doc/git-1.9.0/howto/{html,text}             
mv       /usr/share/doc/git-1.9.0/howto/{*.txt,text}            
mv       /usr/share/doc/git-1.9.0/howto/{*.,}html

tar -xf ../git-manpages-1.9.0.tar.xz -C /usr/share/man --no-same-owner --no-overwrite-dir

mkdir -pv -p /usr/share/doc/git-1.9.0/man-pages/{html,text}         

tar -xf  ../git-htmldocs-1.9.0.tar.xz -C   /usr/share/doc/git-1.9.0 --no-same-owner --no-overwrite-dir 

find /usr/share/doc/git-1.9.0 -type d -exec chmod 755 {} \;     
find /usr/share/doc/git-1.9.0 -type f -exec chmod 644 {} \;     

mv       /usr/share/doc/git-1.9.0/{git*.txt,man-pages/text}     
mv       /usr/share/doc/git-1.9.0/{git*.,index.,man-pages/}html 
mkdir -pv /usr/share/doc/git-1.9.0/technical/{html,text}         
mv       /usr/share/doc/git-1.9.0/technical/{*.txt,text}        
mv       /usr/share/doc/git-1.9.0/technical/{*.,}html           
mkdir -pv /usr/share/doc/git-1.9.0/howto/{html,text}             
mv       /usr/share/doc/git-1.9.0/howto/{*.txt,text}            
mv       /usr/share/doc/git-1.9.0/howto/{*.,}html


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

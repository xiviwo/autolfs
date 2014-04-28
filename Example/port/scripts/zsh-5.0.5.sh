#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=zsh
version=5.0.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.zsh.org/pub/zsh-5.0.5.tar.bz2
nwget http://www.zsh.org/pub/zsh-5.0.5-doc.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" zsh-5.0.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar --strip-components=1 -xvf ../zsh-5.0.5-doc.tar.bz2

sed -e '/attr.mdh/ d' -e '/attr.pro/ d' -e '/include <sys\/xattr.h>/ a\\n#include "attr.mdh"\n#include "attr.pro"' -i Src/Modules/attr.c                             

./configure --prefix=/usr --bindir=/bin --sysconfdir=/etc/zsh --enable-etcdir=/etc/zsh                  
make                                                  

makeinfo  Doc/zsh.texi --html      -o Doc/html        
makeinfo  Doc/zsh.texi --html --no-split --no-headers -o Doc/zsh.html    
makeinfo  Doc/zsh.texi --plaintext -o Doc/zsh.txt

make install 
make infodir=/usr/share/info install.info

install -v -m755 -d /usr/share/doc/zsh-5.0.5/html 
install -v -m644    Doc/html/* /usr/share/doc/zsh-5.0.5/html 
install -v -m644    Doc/zsh.{html,txt} /usr/share/doc/zsh-5.0.5

make htmldir=/usr/share/doc/zsh-5.0.5/html install.html 
install -v -m644 Doc/zsh.dvi /usr/share/doc/zsh-5.0.5

mv -v /usr/lib/libpcre.so.* /lib 
ln -v -sf ../../lib/libpcre.so.0 /usr/lib/libpcre.so

mv -v /usr/lib/libgdbm.so.* /lib 
ln -v -sf ../../lib/libgdbm.so.3 /usr/lib/libgdbm.so

cat >> /etc/shells << "EOF"
/bin/zsh
/bin/zsh-5.0.5
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

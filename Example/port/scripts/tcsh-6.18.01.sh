#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tcsh
version=6.18.01
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.sfr-fresh.com/unix/misc/tcsh-6.18.01.tar.gz
nwget ftp://ftp.astron.com/pub/tcsh/tcsh-6.18.01.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" tcsh-6.18.01.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's|\$\*|#&|' -e 's|fR/g|&m|' tcsh.man2html 

./configure --prefix=/usr --bindir=/bin 
make 
sh ./tcsh.man2html

make install install.man 
ln -v -sf tcsh   /bin/csh 
ln -v -sf tcsh.1 /usr/share/man/man1/csh.1 
install -v -m755 -d          /usr/share/doc/tcsh-6.18.01/html 
install -v -m644 tcsh.html/* /usr/share/doc/tcsh-6.18.01/html 
install -v -m644 FAQ         /usr/share/doc/tcsh-6.18.01

cat >> /etc/shells << "EOF"
/bin/tcsh
/bin/csh
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

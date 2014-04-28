#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gnupg
version=2.0.22
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.22.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gnupg-2.0.22.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/gnupg-2.0.22 
make 

makeinfo --html --no-split -o doc/gnupg_nochunks.html doc/gnupg.texi 
makeinfo --plaintext       -o doc/gnupg.txt           doc/gnupg.texi

make install               
ln -svf gpg2  /usr/bin/gpg  
ln -svf gpgv2 /usr/bin/gpgv 

install -v -m755 -d /usr/share/doc/gnupg-2.0.22/html       
install -v -m644    doc/gnupg_nochunks.html /usr/share/doc/gnupg-2.0.22/gnupg.html 
install -v -m644    doc/*.texi doc/gnupg.txt /usr/share/doc/gnupg-2.0.22


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=enscript
version=1.6.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/enscript/enscript-1.6.6.tar.gz
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/enscript-1.6.6.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" enscript-1.6.6.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc/enscript --localstatedir=/var --with-media=Letter 
make 

pushd docs 
  makeinfo --plaintext -o enscript.txt enscript.texi 
popd

make install 

install -v -m755 -d /usr/share/doc/enscript-1.6.6 
install -v -m644    README* *.txt docs/*.txt /usr/share/doc/enscript-1.6.6


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

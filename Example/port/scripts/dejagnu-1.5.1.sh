#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dejagnu
version=1.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/dejagnu/dejagnu-1.5.1.tar.gz


}
unpack()
{
preparepack "$pkgname" "$version" dejagnu-1.5.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi 
makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi

make install 
install -v -dm755   /usr/share/doc/dejagnu-1.5.1 
install -v -m644    doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.5.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

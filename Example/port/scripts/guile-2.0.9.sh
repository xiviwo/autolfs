#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=guile
version=2.0.9
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/pub/gnu/guile/guile-2.0.9.tar.xz
nwget http://ftp.gnu.org/pub/gnu/guile/guile-2.0.9.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" guile-2.0.9.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/guile-2.0.9 
make      
make html 

makeinfo --plaintext -o doc/r5rs/r5rs.txt doc/r5rs/r5rs.texi 
makeinfo --plaintext -o doc/ref/guile.txt doc/ref/guile.texi

make install      
make install-html 

mv /usr/share/doc/guile-2.0.9/{guile.html,ref} 
mv /usr/share/doc/guile-2.0.9/r5rs{.html,}     

find examples -name "Makefile*" -delete 
cp -vR examples   /usr/share/doc/guile-2.0.9   

for DIRNAME in r5rs ref; do
  install -v -m644  doc/${DIRNAME}/*.txt /usr/share/doc/guile-2.0.9/${DIRNAME}
done 
unset DIRNAME


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

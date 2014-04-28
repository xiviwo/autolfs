#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xsane
version=0.999
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.xsane.org/download/xsane-0.999.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" xsane-0.999.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's/png_ptr->jmpbuf/png_jmpbuf(png_ptr)/' src/xsane-save.c 
./configure --prefix=/usr                                           
make

make xsanedocdir=/usr/share/doc/xsane-0.999 install 
ln -v -s ../../doc/xsane-0.999 /usr/share/sane/xsane/doc

ln -v -s <browser> /usr/bin/netscape

ln -v -s /usr/bin/xsane /usr/lib/gimp/2.0/plug-ins/


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

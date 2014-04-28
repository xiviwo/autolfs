#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=freetype
version=2.5.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/freetype/freetype-doc-2.5.2.tar.bz2
nwget http://downloads.sourceforge.net/freetype/freetype-2.5.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" freetype-2.5.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../freetype-doc-2.5.2.tar.bz2 --strip-components=2 -C docs

sed -i  -e "/AUX.*.gxvalid/s@^# @@" -e "/AUX.*.otvalid/s@^# @@" modules.cfg                        

sed -ri -e 's:.*(#.*SUBPIXEL.*) .*:\1:' include/config/ftoption.h          

./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/freetype-2.5.2 
cp -v -R docs/*     /usr/share/doc/freetype-2.5.2


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

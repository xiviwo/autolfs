#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=a2ps
version=4.14
export MAKEFLAGS='-j 4'
download()
{
nwget http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/i18n-fonts/i18n-fonts-0.1.tar.bz2
nwget ftp://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz
nwget http://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" a2ps-4.14.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
autoconf 
sed -i -e "s/GPERF --version |/& head -n 1 |/" -e "s|/usr/local/share|/usr/share|" configure 

./configure --prefix=/usr --sysconfdir=/etc/a2ps --enable-shared --with-medium=letter   
make                       
touch doc/*.info

make install

tar -xf ../i18n-fonts-0.1.tar.bz2 
cp -v i18n-fonts-0.1/fonts/* /usr/share/a2ps/fonts               
cp -v i18n-fonts-0.1/afm/* /usr/share/a2ps/afm                   
pushd /usr/share/a2ps/afm    
  ./make_fonts_map.sh        
  mv fonts.map.new fonts.map 
popd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

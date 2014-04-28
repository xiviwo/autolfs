#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=php
version=5.5.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/php-5.5.9-libmagic_fix-1.patch
nwget http://www.php.net/download-docs.php
nwget http://us2.php.net/distributions/php-5.5.9.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" php-5.5.9.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../php-5.5.9-libmagic_fix-1.patch 
sed -i -e 's/2.6.5 2.7/& 3.0/' configure 
./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --with-apxs2 --with-config-file-path=/etc --with-zlib --enable-bcmath --with-bz2 --enable-calendar --enable-dba=shared --with-gdbm --with-gmp --enable-ftp --with-gettext --enable-mbstring --with-readline              
make

make install                                         
install -v -m644 php.ini-production /etc/php.ini     

install -v -m755 -d /usr/share/doc/php-5.5.9 
install -v -m644    CODING_STANDARDS EXTENSIONS INSTALL NEWS README* UPGRADING* php.gif /usr/share/doc/php-5.5.9 
ln -v -sfn          /usr/lib/php/doc/Archive_Tar/docs/Archive_Tar.txt /usr/share/doc/php-5.5.9 
ln -v -sfn          /usr/lib/php/doc/Structures_Graph/docs /usr/share/doc/php-5.5.9

install -v -m644 ../php_manual_en.html.gz /usr/share/doc/php-5.5.9 
gunzip -v /usr/share/doc/php-5.5.9/php_manual_en.html.gz

tar -xvf ../php_manual_en.tar.gz -C /usr/share/doc/php-5.5.9 --no-same-owner

sed -i 's@php/includes"@&\ninclude_path = ".:/usr/lib/php"@' /etc/php.ini


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

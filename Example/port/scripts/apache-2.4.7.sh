#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=apache
version=2.4.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/httpd/httpd-2.4.7.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/httpd-2.4.7-blfs_layout-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" httpd-2.4.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 25 apache 
useradd -c "Apache Server" -d /srv/www -g apache -s /bin/false -u 25 apache

patch -Np1 -i ../httpd-2.4.7-blfs_layout-1.patch 
sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in 
./configure --enable-layout=BLFS --enable-mods-shared="all cgi" --enable-mpms-shared=all --with-apr=/usr/bin/apr-1-config --with-apr-util=/usr/bin/apu-1-config --enable-suexec=shared --with-suexec-bin=/usr/lib/httpd/suexec --with-suexec-docroot=/srv/www --with-suexec-caller=apache --with-suexec-userdir=public_html --with-suexec-logfile=/var/log/httpd/suexec.log --with-suexec-uidmin=100 
make

make install                                 

mv -v /usr/sbin/suexec /usr/lib/httpd/suexec 
chgrp apache           /usr/lib/httpd/suexec 
chmod 4754             /usr/lib/httpd/suexec 

chown -v -R apache:apache /srv/www

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-httpd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

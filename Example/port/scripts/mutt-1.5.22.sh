#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mutt
version=1.5.22
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.mutt.org/mutt/devel/mutt-1.5.22.tar.gz
nwget http://downloads.sourceforge.net/mutt/mutt-1.5.22.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" mutt-1.5.22.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 34 mail

chgrp -v mail /var/mail

./configure --prefix=/usr --sysconfdir=/etc --with-docdir=/usr/share/doc/mutt-1.5.22 --enable-pop --enable-imap --enable-hcache --without-qdbm --without-tokyocabinet --with-gdbm --without-bdb 
make

make install

cat /usr/share/doc/mutt-1.5.22/samples/gpg.rc >> ~/.muttrc


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=shadow
version=4.1.5.1
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" shadow_4.1.5.1.orig.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;

@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' -e 's@/var/spool/mail@/var/mail@' etc/login.defs

sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs

./configure --sysconfdir=/etc --with-libpam=no --with-attr=no --with-selinux=no --with-audit=no --with-acl=no

make

make install

mv -v /usr/bin/passwd /bin

pwconv

grpconv

sed -i 's/yes/no/' /etc/default/useradd

echo 'root:ping' | chpasswd

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

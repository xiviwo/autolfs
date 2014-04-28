#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=linux-pam
version=1.1.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://linux-pam.org/library/Linux-PAM-1.1.8.tar.bz2
nwget http://linux-pam.org/documentation/Linux-PAM-1.1.8-docs.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" Linux-PAM-1.1.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../Linux-PAM-1.1.8-docs.tar.bz2 --strip-components=1

./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --enable-securedir=/lib/security --docdir=/usr/share/doc/Linux-PAM-1.1.8 
make

install -v -m755 -d /etc/pam.d 

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

rm -rfv /etc/pam.d

make install 
chmod -v 4755 /sbin/unix_chkpwd 

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib 
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

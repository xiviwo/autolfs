#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=polkit
version=0.112
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/polkit/releases/polkit-0.112.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" polkit-0.112.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -fg 27 polkitd 
useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 -g polkitd -s /bin/false polkitd

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --with-authfw=shadow 
make

make install

cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1

auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/polkit-1
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

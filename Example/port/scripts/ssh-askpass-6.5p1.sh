#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ssh-askpass
version=6.5p1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
nwget ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" openssh-6.5p1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd contrib 
make gnome-ssh-askpass2

install -v -d -m755                  /usr/lib/openssh/contrib     
install -v -m755  gnome-ssh-askpass2 /usr/lib/openssh/contrib     
ln -svf -f contrib/gnome-ssh-askpass2 /usr/lib/openssh/ssh-askpass

cat >> /etc/sudo.conf << "EOF" 
# Path to askpass helper program
Path askpass /usr/lib/openssh/ssh-askpass
EOF
chmod -v 0644 /etc/sudo.conf


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

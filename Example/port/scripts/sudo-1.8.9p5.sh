#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sudo
version=1.8.9p5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.sudo.ws/pub/sudo/sudo-1.8.9p5.tar.gz
nwget http://www.sudo.ws/sudo/dist/sudo-1.8.9p5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" sudo-1.8.9p5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --libexecdir=/usr/lib/sudo --docdir=/usr/share/doc/sudo-1.8.9p5 --with-timedir=/var/lib/sudo --with-all-insults --with-env-editor --with-passprompt="[sudo] password for %p" 
make

make install

cat > /etc/pam.d/sudo << "EOF"
# Begin /etc/pam.d/sudo

# include the default auth settings
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/sudo
EOF
chmod 644 /etc/pam.d/sudo


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

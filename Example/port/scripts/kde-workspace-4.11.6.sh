#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=kde-workspace
version=4.11.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/4.12.2/src/kde-workspace-4.11.6.tar.xz
nwget ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/kde-workspace-4.11.6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" kde-workspace-4.11.6.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 37 kdm 
useradd -c "KDM Daemon Owner" -d /var/lib/kdm -g kdm -u 37 -s /bin/false kdm 
install -o kdm -g kdm -dm755 /var/lib/kdm

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -DINSTALL_PYTHON_FILES_IN_PYTHON_PREFIX=TRUE -Wno-dev .. 
make

make install                  
mkdir -pv -p /usr/share/xsessions 
ln -sf $KDE_PREFIX/share/apps/kdm/sessions/kde-plasma.desktop /usr/share/xsessions/kde-plasma.desktop

cat >> /etc/pam.d/kde << "EOF" 
# Begin /etc/pam.d/kde

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde
EOF
cat > /etc/pam.d/kde-np << "EOF" 
# Begin /etc/pam.d/kde-np

auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account
password include        system-password
session  include        system-session

# End /etc/pam.d/kde-np
EOF
cat > /etc/pam.d/kscreensaver << "EOF"
# Begin /etc/pam.d/kscreensaver

auth    include system-auth
account include system-account

# End /etc/pam.d/kscreensaver
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

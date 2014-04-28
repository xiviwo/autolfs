#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=starting-kde
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{

cd ${SOURCES} 

}
build()
{
cat > ~/.xinitrc << EOF
# Begin .xinitrc

exec ck-launch-session dbus-launch --exit-with-session startkde

# End .xinitrc
EOF

cat >> /etc/inittab << EOF
kd:5:respawn:/opt/kde/bin/kdm
EOF

sed -i 's#id:3:initdefault:#id:5:initdefault:#' /etc/inittab


}
download;unpack;build

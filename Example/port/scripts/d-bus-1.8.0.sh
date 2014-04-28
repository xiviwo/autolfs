#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=d-bus
version=1.8.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/hints/downloads/files/execute-session-scripts-using-kdm.txt
nwget http://dbus.freedesktop.org/releases/dbus/dbus-1.8.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dbus-1.8.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 18 messagebus  || :
useradd -c "D-Bus Message Daemon User" -d /var/run/dbus -u 18 -g messagebus -s /bin/false messagebus || :

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-console-auth-dir=/run/console/ --without-systemdsystemunitdir --disable-systemd --disable-static 
make

make install 
mv -v /usr/share/doc/dbus /usr/share/doc/dbus-1.8.0

dbus-uuidgen --ensure


cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/local -->
  <servicedir>/usr/local/share/dbus-1/services</servicedir>

</busconfig>
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-dbus

# Start the D-Bus session daemon
eval `dbus-launch`
export DBUS_SESSION_BUS_ADDRESS

# Kill the D-Bus session daemon
kill $DBUS_SESSION_BUS_PID


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

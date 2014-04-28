#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=wpa-supplicant
version=2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://hostap.epitest.fi/releases/wpa_supplicant-2.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" wpa_supplicant-2.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cat > wpa_supplicant/.config << "EOF"
CONFIG_BACKEND=file
CONFIG_CTRL_IFACE=y
CONFIG_DEBUG_FILE=y
CONFIG_DEBUG_SYSLOG=y
CONFIG_DEBUG_SYSLOG_FACILITY=LOG_DAEMON
CONFIG_DRIVER_NL80211=y
CONFIG_DRIVER_WEXT=y
CONFIG_DRIVER_WIRED=y
CONFIG_EAP_GTC=y
CONFIG_EAP_LEAP=y
CONFIG_EAP_MD5=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_OTP=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_TLS=y
CONFIG_EAP_TTLS=y
CONFIG_IEEE8021X_EAPOL=y
CONFIG_IPV6=y
CONFIG_LIBNL32=y
CONFIG_PEERKEY=y
CONFIG_PKCS12=y
CONFIG_READLINE=y
CONFIG_SMARTCARD=y
CONFIG_WPS=y
CFLAGS += -I/usr/include/libnl3
EOF

cat >> wpa_supplicant/.config << "EOF"
CONFIG_CTRL_IFACE_DBUS=y
CONFIG_CTRL_IFACE_DBUS_NEW=y
CONFIG_CTRL_IFACE_DBUS_INTRO=y
EOF

cd wpa_supplicant 
make BINDIR=/sbin LIBDIR=/lib

pushd wpa_gui-qt4 
qmake wpa_gui.pro 
make 
popd

install -v -m755 wpa_{cli,passphrase,supplicant} /sbin/ 
install -v -m644 doc/docbook/wpa_supplicant.conf.5 /usr/share/man/man5/ 
install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 /usr/share/man/man8/

install -v -m644 dbus/fi.{epitest.hostap.WPASupplicant,w1.wpa_supplicant1}.service /usr/share/dbus-1/system-services/ 
install -v -m644 dbus/dbus-wpa_supplicant.conf /etc/dbus-1/system.d/wpa_supplicant.conf

install -v -m755 wpa_gui-qt4/wpa_gui /usr/bin/ 
install -v -m644 doc/docbook/wpa_gui.8 /usr/share/man/man8/ 
install -v -m644 wpa_gui-qt4/wpa_gui.desktop /usr/share/applications/ 
install -v -m644 wpa_gui-qt4/icons/wpa_gui.svg /usr/share/pixmaps/

update-desktop-database

wpa_passphrase SSID SECRET_PASSWORD > /etc/sysconfig/wpa_supplicant-wifi0.conf

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-service-wpa

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="dhclient"
DHCP_START=""
DHCP_STOP=""

# Set PRINTIP="yes" to have the script print
# the DHCP assigned IP address
PRINTIP="no"

# Set PRINTALL="yes" to print the DHCP assigned values for
# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".
PRINTALL="no"
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="dhcpcd"
DHCP_START="-b -q <insert appropriate start options here>"
DHCP_STOP="-k <insert additional stop options here>"
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.wifi0 << "EOF"
ONBOOT="yes"
IFACE="wlan0"
SERVICE="wpa"

# Additional arguments to wpa_supplicant
WPA_ARGS=""

WPA_SERVICE="ipv4-static"
IP="192.168.1.1"
GATEWAY="192.168.1.2"
PREFIX="24"
BROADCAST="192.168.1.255"
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

ifup wifi0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

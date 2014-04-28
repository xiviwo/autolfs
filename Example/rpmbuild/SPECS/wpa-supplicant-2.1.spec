%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     WPA Supplicant is a Wi-Fi Protected Access (WPA) client and IEEE 802.1X supplicant. It implements WPA key negotiation with a WPA Authenticator and Extensible Authentication Protocol (EAP) authentication with an Authentication Server. In addition, it controls the roaming and IEEE 802.11 authentication/association of the wireless LAN driver. This is useful for connecting to a password protected wireless access point. 
Name:       wpa-supplicant
Version:    2.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libnl
Requires:  openssl
Source0:    http://hostap.epitest.fi/releases/wpa_supplicant-2.1.tar.gz
URL:        http://hostap.epitest.fi/releases
%description
 WPA Supplicant is a Wi-Fi Protected Access (WPA) client and IEEE 802.1X supplicant. It implements WPA key negotiation with a WPA Authenticator and Extensible Authentication Protocol (EAP) authentication with an Authentication Server. In addition, it controls the roaming and IEEE 802.11 authentication/association of the wireless LAN driver. This is useful for connecting to a password protected wireless access point. 
%pre
install -v -m755 wpa_{cli,passphrase,supplicant} /sbin/ &&

install -v -m644 doc/docbook/wpa_supplicant.conf.5 /usr/share/man/man5/ &&

install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 /usr/share/man/man8/

install -v -m644 dbus/fi.{epitest.hostap.WPASupplicant,w1.wpa_supplicant1}.service /usr/share/dbus-1/system-services/ &&

install -v -m644 dbus/dbus-wpa_supplicant.conf /etc/dbus-1/system.d/wpa_supplicant.conf

install -v -m755 wpa_gui-qt4/wpa_gui /usr/bin/ &&

install -v -m644 doc/docbook/wpa_gui.8 /usr/share/man/man8/ &&

install -v -m644 wpa_gui-qt4/wpa_gui.desktop /usr/share/applications/ &&

install -v -m644 wpa_gui-qt4/icons/wpa_gui.svg /usr/share/pixmaps/
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
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
cd wpa_supplicant &&
make BINDIR=/sbin LIBDIR=/lib %{?_smp_mflags} 

pushd wpa_gui-qt4 &&
qmake wpa_gui.pro &&
make && %{?_smp_mflags} 

popd
update-desktop-database
wpa_passphrase SSID SECRET_PASSWORD > /etc/sysconfig/wpa_supplicant-wifi0.conf
mkdir -pv /etc
mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd wpa_supplicant &&

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make install-service-wpa DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
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
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
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
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
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
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
ifup wifi0

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     NetworkManager is a set of co-operative tools that make networking simple and straightforward. Whether WiFi, wired, 3G, or Bluetooth, NetworkManager allows you to quickly move from one network to another: Once a network has been configured and joined once, it can be detected and re-joined automatically the next time it's available. 
Name:       networkmanager
Version:    0.9.8.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  dbus-glib
Requires:  intltool
Requires:  libnl
Requires:  nss
Requires:  udev-extras-from-systemd
Requires:  consolekit
Requires:  dhcpcd
Requires:  gobject-introspection
Requires:  iptables
Requires:  libsoup
Requires:  polkit
Requires:  upower
Requires:  vala
Source0:    http://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.9/NetworkManager-0.9.8.8.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.9/NetworkManager-0.9.8.8.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.9
%description
 NetworkManager is a set of co-operative tools that make networking simple and straightforward. Whether WiFi, wired, 3G, or Bluetooth, NetworkManager allows you to quickly move from one network to another: Once a network has been configured and joined once, it can be detected and re-joined automatically the next time it's available. 
%pre
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-ppp &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/NetworkManager
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-networkmanager DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"

[main]

plugins=keyfile

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
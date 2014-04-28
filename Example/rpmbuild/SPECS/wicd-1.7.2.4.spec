%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Wicd is a network manager written in Python. It simplifies network setup by automatically detecting and connecting to wireless and wired networks. Wicd includes support for WPA authentication and DHCP configuration. It provides Curses- and GTK-based graphical frontends for user-friendly control. An excellent KDE-based frontend is also available here. 
Name:       wicd
Version:    1.7.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Requires:  d-bus-python
Requires:  wireless-tools
Requires:  net-tools-cvs-cvs
Requires:  pygtk
Requires:  wpa-supplicant
Requires:  dhcpcd
Source0:    http://launchpad.net/wicd/1.7/1.7.2.4/+download/wicd-1.7.2.4.tar.gz
URL:        http://launchpad.net/wicd/1.7/1.7.2.4/+download
%description
 Wicd is a network manager written in Python. It simplifies network setup by automatically detecting and connecting to wireless and wired networks. Wicd includes support for WPA authentication and DHCP configuration. It provides Curses- and GTK-based graphical frontends for user-friendly control. An excellent KDE-based frontend is also available here. 
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
sed -i '/wpath.logrotate\|wpath.systemd/d' setup.py &&
rm po/*.po                                          &&
python setup.py configure --no-install-kde --no-install-acpi --no-install-pmutils --no-install-init
python setup.py install
mkdir -pv /etc
mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ${SOURCES}/blfs-boot-scripts


make install-wicd DESTDIR=${RPM_BUILD_ROOT} 


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The acpid (Advanced Configuration and Power Interface event daemon) is a completely flexible, totally extensible daemon for delivering ACPI events. It listens on netlink interface and when an event occurs, executes programs to handle the event. The programs it executes are configured through a set of configuration files, which can be dropped into place by packages or by the user. 
Name:       acpid
Version:    2.0.21
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/acpid2/acpid-2.0.21.tar.xz
URL:        http://downloads.sourceforge.net/acpid2
%description
 The acpid (Advanced Configuration and Power Interface event daemon) is a completely flexible, totally extensible daemon for delivering ACPI events. It listens on netlink interface and when an event occurs, executes programs to handle the event. The programs it executes are configured through a set of configuration files, which can be dropped into place by packages or by the user. 
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
./configure --prefix=/usr --docdir=/usr/share/doc/acpid-2.0.21 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/acpi/events
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/acpi
make install                         && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/etc/acpi/events &&

cp -r samples ${RPM_BUILD_ROOT}/usr/share/doc/acpid-2.0.21

cat > /etc/acpi/events/lid << "EOF"
event=button/lid
action=/etc/acpi/lid.sh
EOF
cat > /etc/acpi/lid.sh << "EOF"
#!/bin/sh
/bin/grep -q open /proc/acpi/button/lid/LID/state && exit 0
/usr/sbin/pm-suspend
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-acpid DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod +x /etc/acpi/lid.sh
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
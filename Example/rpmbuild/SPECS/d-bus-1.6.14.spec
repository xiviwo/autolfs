%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     D-Bus is a message bus system, a simple way for applications to talk to one another. D-Bus supplies both a system daemon (for events such as “new hardware device added” or “printer queue changed”) and a per-user-login-session daemon (for general IPC needs among user applications). Also, the message bus is built on top of a general one-to-one message passing framework, which can be used by any two applications to communicate directly (without going through the message bus daemon). 
Name:       d-bus
Version:    1.6.14
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  xorg-libraries
Source0:    http://dbus.freedesktop.org/releases/dbus/dbus-1.6.14.tar.gz
Source1:    http://www.linuxfromscratch.org/hints/downloads/files/execute-session-scripts-using-kdm.txt
URL:        http://dbus.freedesktop.org/releases/dbus
%description
 D-Bus is a message bus system, a simple way for applications to talk to one another. D-Bus supplies both a system daemon (for events such as “new hardware device added” or “printer queue changed”) and a per-user-login-session daemon (for general IPC needs among user applications). Also, the message bus is built on top of a general one-to-one message passing framework, which can be used by any two applications to communicate directly (without going through the message bus daemon). 
%pre
groupadd -g 18 messagebus

useradd -c "D-Bus Message Daemon User" -d /var/run/dbus -u 18 -g messagebus -s /bin/false messagebus
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/lib/dbus-1.0 --with-console-auth-dir=/run/console/ --without-systemdsystemunitdir --disable-systemd --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/dbus-1.6.14
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/dbus
make install  DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/share/doc/dbus ${RPM_BUILD_ROOT}/usr/share/doc/dbus-1.6.14

dbus-uuidgen --ensure

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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The D-Bus GLib package contains GLib interfaces to the D-Bus API. 
Name:       dbus-glib
Version:    0.100.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  d-bus
Requires:  expat
Requires:  glib
Source0:    http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.100.2.tar.gz
URL:        http://dbus.freedesktop.org/releases/dbus-glib
%description
 The D-Bus GLib package contains GLib interfaces to the D-Bus API. 
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
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/dbus-1.0 --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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
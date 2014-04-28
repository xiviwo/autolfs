%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The UDisks package provides a storage daemon that implements well-defined D-Bus interfaces that can be used to query and manipulate storage devices. 
Name:       udisks
Version:    1.0.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  dbus-glib
Requires:  libatasmart
Requires:  lvm2
Requires:  parted
Requires:  polkit
Requires:  sg3-utils
Requires:  udev-extras-from-systemd
Source0:    http://hal.freedesktop.org/releases/udisks-1.0.4.tar.gz
URL:        http://hal.freedesktop.org/releases
%description
 The UDisks package provides a storage daemon that implements well-defined D-Bus interfaces that can be used to query and manipulate storage devices. 
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make profiledir=${RPM_BUILD_ROOT}/etc/bash_completion.d install DESTDIR=${RPM_BUILD_ROOT} 


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
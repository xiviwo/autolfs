%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libgusb package contains the GObject wrappers for libusb-1.0 that makes it easy to do asynchronous control, bulk and interrupt transfers with proper cancellation and integration into a mainloop. 
Name:       libgusb
Version:    0.1.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libusb
Requires:  udev-extras-from-systemd
Requires:  gobject-introspection
Requires:  vala
Source0:    http://people.freedesktop.org/~hughsient/releases/libgusb-0.1.6.tar.xz
URL:        http://people.freedesktop.org/~hughsient/releases
%description
 The libgusb package contains the GObject wrappers for libusb-1.0 that makes it easy to do asynchronous control, bulk and interrupt transfers with proper cancellation and integration into a mainloop. 
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
./configure --prefix=/usr --disable-static &&
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libnice package is an implementation of the IETF's draft Interactive Connectivity Establishment standard (ICE). It provides GLib-based library, libnice and GStreamer, elements. 
Name:       libnice
Version:    0.1.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  gst-plugins-base
Source0:    http://nice.freedesktop.org/releases/libnice-0.1.4.tar.gz
URL:        http://nice.freedesktop.org/releases
%description
 The libnice package is an implementation of the IETF's draft Interactive Connectivity Establishment standard (ICE). It provides GLib-based library, libnice and GStreamer, elements. 
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
./configure --prefix=/usr --disable-static --without-gstreamer-0.10 &&
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
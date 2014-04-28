%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Bad Plug-ins package contains a set a set of plug-ins that aren't up to par compared to the rest. They might be close to being good quality, but they're missing something - be it a good code review, some documentation, a set of tests, a real live maintainer, or some actual wide use. 
Name:       gst-plugins-bad
Version:    1.0.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  libdvdread
Requires:  libdvdnav
Requires:  soundtouch
Source0:    http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-1.0.10.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gst-plugins-bad
%description
 The GStreamer Bad Plug-ins package contains a set a set of plug-ins that aren't up to par compared to the rest. They might be close to being good quality, but they're missing something - be it a good code review, some documentation, a set of tests, a real live maintainer, or some actual wide use. 
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
./configure --prefix=/usr --with-package-name="GStreamer Bad Plugins 1.0.10 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 
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
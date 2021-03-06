%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Ugly Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality and correct functionality, but distributing them might pose problems. The license on either the plug-ins or the supporting libraries might not be how the GStreamer developers would like. The code might be widely known to present patent problems. 
Name:       gst-plugins-ugly
Version:    1.2.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  lame
Requires:  libdvdread
Requires:  x264
Source0:    http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.2.3.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gst-plugins-ugly
%description
 The GStreamer Ugly Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality and correct functionality, but distributing them might pose problems. The license on either the plug-ins or the supporting libraries might not be how the GStreamer developers would like. The code might be widely known to present patent problems. 
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
./configure --prefix=/usr --with-package-name="GStreamer Ugly Plugins 1.2.3 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
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
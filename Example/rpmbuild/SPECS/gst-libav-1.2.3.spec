%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Libav package contains GStreamer plugins for Libav (a fork of FFmpeg). 
Name:       gst-libav
Version:    1.2.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  yasm
Source0:    http://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.2.3.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gst-libav
%description
 The GStreamer Libav package contains GStreamer plugins for Libav (a fork of FFmpeg). 
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
./configure --prefix=/usr --with-package-name="GStreamer Libav Plugins 1.2.3 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" &&
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
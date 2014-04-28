%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Base Plug-ins is a well-groomed and well-maintained collection of GStreamer plug-ins and elements, spanning the range of possible types of elements one would want to write for GStreamer. You will need at least one of Good, Bad, Ugly or Libav plugins for GStreamer applications to function properly. 
Name:       gst-plugins-base
Version:    1.0.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gstreamer
Requires:  libxml2
Requires:  alsa-lib
Requires:  gobject-introspection
Requires:  iso-codes
Requires:  libogg
Requires:  libtheora
Requires:  libvorbis
Requires:  pango
Requires:  xorg-libraries
Source0:    http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.0.10.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gst-plugins-base
%description
 The GStreamer Base Plug-ins is a well-groomed and well-maintained collection of GStreamer plug-ins and elements, spanning the range of possible types of elements one would want to write for GStreamer. You will need at least one of Good, Bad, Ugly or Libav plugins for GStreamer applications to function properly. 
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
./configure --prefix=/usr --with-package-name="GStreamer Base Plugins 1.0.10 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 
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
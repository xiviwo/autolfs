%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Base Plug-ins is a well-groomed and well-maintained collection of GStreamer plug-ins and elements, spanning the range of possible types of elements one would want to write for GStreamer. It also contains helper libraries and base classes useful for writing elements. A wide range of video and audio decoders, encoders, and filters are included. Also see the gst-plugins-bad-0.10.23, gst-plugins-good-0.10.31, gst-plugins-ugly-0.10.19, and gst-ffmpeg-0.10.13 packages. 
Name:       gst-plugins-base
Version:    0.10.36
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gstreamer
Requires:  pango
Requires:  alsa-lib
Requires:  libogg
Requires:  libtheora
Requires:  libvorbis
Requires:  udev-extras-from-systemd
Requires:  xorg-libraries
Source0:    http://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10
%description
 The GStreamer Base Plug-ins is a well-groomed and well-maintained collection of GStreamer plug-ins and elements, spanning the range of possible types of elements one would want to write for GStreamer. It also contains helper libraries and base classes useful for writing elements. A wide range of video and audio decoders, encoders, and filters are included. Also see the gst-plugins-bad-0.10.23, gst-plugins-good-0.10.31, gst-plugins-ugly-0.10.19, and gst-ffmpeg-0.10.13 packages. 
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
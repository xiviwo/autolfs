%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Good Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality code, correct functionality, and the preferred license (LGPL for the plug-in code, LGPL or LGPL-compatible for the supporting library). A wide range of video and audio decoders, encoders, and filters are included. Also see the gst-plugins-ugly-0.10.19, gst-plugins-bad-0.10.23 and gst-ffmpeg-0.10.13 packages. 
Name:       gst-plugins-good
Version:    0.10.31
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  cairo
Requires:  flac
Requires:  libjpeg-turbo
Requires:  libpng
Requires:  xorg-libraries
Source0:    http://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10
%description
 The GStreamer Good Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality code, correct functionality, and the preferred license (LGPL for the plug-in code, LGPL or LGPL-compatible for the supporting library). A wide range of video and audio decoders, encoders, and filters are included. Also see the gst-plugins-ugly-0.10.19, gst-plugins-bad-0.10.23 and gst-ffmpeg-0.10.13 packages. 
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
sed -i -e "/input:/d" sys/v4l2/gstv4l2bufferpool.c &&
sed -i -e "/case V4L2_CID_HCENTER/d" -e "/case V4L2_CID_VCENTER/d" sys/v4l2/v4l2_calls.c &&
./configure --prefix=/usr --sysconfdir=/etc --with-gtk=3.0 &&
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
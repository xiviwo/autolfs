%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     GStreamer is a streaming media framework that enables applications to share a common set of plugins for things like video encoding and decoding, audio encoding and decoding, audio and video filters, audio visualisation, web streaming and anything else that streams in real-time or otherwise. This package only provides base functionality and libraries. You may need at least gst-plugins-base-1.0.10 and one of Good, Bad, Ugly or Libav plugins. 
Name:       gstreamer
Version:    1.0.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  gobject-introspection
Source0:    http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.0.10.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gstreamer
%description
 GStreamer is a streaming media framework that enables applications to share a common set of plugins for things like video encoding and decoding, audio encoding and decoding, audio and video filters, audio visualisation, web streaming and anything else that streams in real-time or otherwise. This package only provides base functionality and libraries. You may need at least gst-plugins-base-1.0.10 and one of Good, Bad, Ugly or Libav plugins. 
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
./configure --prefix=/usr --libexecdir=/usr/lib --with-package-name="GStreamer 1.0.10 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 
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
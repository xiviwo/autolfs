%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     GStreamer is a streaming media framework that enables applications to share a common set of plugins for things like video decoding and encoding, audio encoding and decoding, audio and video filters, audio visualisation, Web streaming and anything else that streams in real-time or otherwise. It is modelled after research software worked on at the Oregon Graduate Institute. After installing GStreamer, you'll likely need to install one or more of the gst-plugins-bad-0.10.23, gst-plugins-good-0.10.31, gst-plugins-ugly-0.10.19 and gst-ffmpeg-0.10.13 packages. 
Name:       gstreamer
Version:    0.10.36
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  libxml2
Source0:    http://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10
%description
 GStreamer is a streaming media framework that enables applications to share a common set of plugins for things like video decoding and encoding, audio encoding and decoding, audio and video filters, audio visualisation, Web streaming and anything else that streams in real-time or otherwise. It is modelled after research software worked on at the Oregon Graduate Institute. After installing GStreamer, you'll likely need to install one or more of the gst-plugins-bad-0.10.23, gst-plugins-good-0.10.31, gst-plugins-ugly-0.10.19 and gst-ffmpeg-0.10.13 packages. 
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
sed -i  -e '/YYLEX_PARAM/d' -e '/parse-param.*scanner/i %lex-param { void *scanner }' gst/parse/grammar.y &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/*
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/design
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/faq
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/design &&

install -v -m644 docs/design/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/design &&

if [ -d ${RPM_BUILD_ROOT}/usr/share/doc/gstreamer-0.10/faq/html ]; then

fi
gst-launch -v fakesrc num_buffers=5 ! fakesink

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
    chown -v -R root:root /usr/share/doc/gstreamer-0.10/*/html
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
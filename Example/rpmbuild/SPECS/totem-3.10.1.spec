%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Totem package contains the official movie player of the GNOME Desktop based on GStreamer. It features a playlist, a full-screen mode, seek and volume controls, as well as keyboard navigation. This is useful for playing any GStreamer supported file, DVD, VCD or digital CD. 
Name:       totem
Version:    3.10.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  clutter-gst
Requires:  clutter-gtk
Requires:  gnome-icon-theme
Requires:  gst-plugins-bad
Requires:  gst-plugins-good
Requires:  libpeas
Requires:  totem-pl-parser
Requires:  yelp-xsl
Requires:  dbus-glib
Requires:  grilo
Requires:  grilo-plugins
Requires:  nautilus
Requires:  pygobject
Requires:  vala
Requires:  gst-libav
Requires:  gst-plugins-ugly
Requires:  libdvdcss
Source0:    http://ftp.gnome.org/pub/gnome/sources/totem/3.10/totem-3.10.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/totem/3.10/totem-3.10.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/totem/3.10
%description
 Totem package contains the official movie player of the GNOME Desktop based on GStreamer. It features a playlist, a full-screen mode, seek and volume controls, as well as keyboard navigation. This is useful for playing any GStreamer supported file, DVD, VCD or digital CD. 
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
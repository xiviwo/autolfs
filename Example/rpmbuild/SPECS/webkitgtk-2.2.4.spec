%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The WebKitGTK+ is the port of the portable web rendering engine WebKit to the GTK+ 3 platform. 
Name:       webkitgtk
Version:    2.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gperf
Requires:  gst-plugins-base
Requires:  gtk
Requires:  icu
Requires:  libsecret
Requires:  libsoup
Requires:  libwebp
Requires:  mesalib
Requires:  ruby
Requires:  sqlite
Requires:  udev-extras-from-systemd
Requires:  which
Requires:  enchant
Requires:  geoclue
Requires:  gobject-introspection
Requires:  hicolor-icon-theme
Source0:    http://webkitgtk.org/releases/webkitgtk-2.2.4.tar.xz
URL:        http://webkitgtk.org/releases
%description
 The WebKitGTK+ is the port of the portable web rendering engine WebKit to the GTK+ 3 platform. 
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
sed -i '/generate-gtkdoc --rebase/s:^:# :' GNUmakefile.in
./configure --prefix=/usr --enable-introspection &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html
make install                                    && DESTDIR=${RPM_BUILD_ROOT} 

rm -rf ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/webkitgtk-2.0    &&

mv -vi ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/webkitgtk{,-2.0}


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
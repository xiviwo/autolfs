%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The WebKitGTK+ is the port of the portable web rendering engine WebKit to the GTK+ 2 platform. 
Name:       webkitgtk
Version:    1.10.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gperf
Requires:  gst-plugins-base
Requires:  gtk
Requires:  icu
Requires:  libsoup
Requires:  mesalib
Requires:  ruby
Requires:  sqlite
Requires:  which
Requires:  enchant
Requires:  geoclue
Requires:  hicolor-icon-theme
Source0:    http://webkitgtk.org/releases/webkitgtk-1.10.2.tar.xz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/webkitgtk-1.10.2-fix_librt_linking-1.patch
URL:        http://webkitgtk.org/releases
%description
 The WebKitGTK+ is the port of the portable web rendering engine WebKit to the GTK+ 2 platform. 
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
sed -i '/parse-param/ a%lex-param {YYLEX_PARAM}' Source/ThirdParty/ANGLE/src/compiler/glslang.y
patch -Np1 -i %_sourcedir/webkitgtk-1.10.2-fix_librt_linking-1.patch &&
./configure --prefix=/usr --with-gtk=2.0 --disable-webkit2 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/webkitgtk-1.0
make install                                    && DESTDIR=${RPM_BUILD_ROOT} 

rm -rf ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/webkitgtk-1.0    &&

mv -vi ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/webkitgtk{,-1.0}


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
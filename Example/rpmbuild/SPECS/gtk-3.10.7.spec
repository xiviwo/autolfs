%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GTK+ 3 package contains the libraries used for creating graphical user interfaces for applications. 
Name:       gtk
Version:    3.10.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  at-spi2-atk-spi2
Requires:  gdk-pixbuf
Requires:  pango
Source0:    http://ftp.gnome.org/pub/gnome/sources/gtk+/3.10/gtk+-3.10.7.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gtk+/3.10/gtk+-3.10.7.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gtk+/3.10
%description
 The GTK+ 3 package contains the libraries used for creating graphical user interfaces for applications. 
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
./configure --prefix=/usr --sysconfdir=/etc --enable-broadway-backend --enable-x11-backend --disable-wayland-backend &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/gtk-3.0
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/glib-2.0/schemas
make install DESTDIR=${RPM_BUILD_ROOT} 

gtk-query-immodules-3.0 --update-cache
glib-compile-schemas ${RPM_BUILD_ROOT}/usr/share/glib-2.0/schemas

cat > /etc/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Clearwaita
gtk-fallback-icon-theme = elementary
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
mkdir -pv -p ~/.config/gtk-3.0 &&

cat > ~/.config/gtk-3.0/settings.ini << "EOF"

[Settings]

gtk-theme-name = Adwaita

gtk-fallback-icon-theme = gnome

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
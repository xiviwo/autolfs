%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GTK+ 2 package contains libraries used for creating graphical user interfaces for applications. 
Name:       gtk
Version:    2.24.20
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  atk
Requires:  gdk-pixbuf
Requires:  pango
Requires:  hicolor-icon-theme
Source0:    http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.20.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.20.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24
%description
 The GTK+ 2 package contains libraries used for creating graphical user interfaces for applications. 
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
sed -i 's#l \(gtk-.*\).sgml#& -o \1#' docs/{faq,tutorial}/Makefile.in 
sed -i 's#.*@man_#man_#' docs/reference/gtk/Makefile.in               
./configure --prefix=/usr --sysconfdir=/etc                           
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/gtk-2.0
make install DESTDIR=${RPM_BUILD_ROOT} 

gtk-query-immodules-2.0 --update-cache
cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat > ~/.gtkrc-2.0 << "EOF"

include "/usr/share/themes/Glider/gtk-2.0/gtkrc"

gtk-icon-theme-name = "hicolor"

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
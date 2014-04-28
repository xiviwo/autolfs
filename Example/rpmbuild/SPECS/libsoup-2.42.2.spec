%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libsoup is HTTP client/server library for GNOME. It uses GObject and the GLib main loop to integrate with GNOME applications and it also has asynchronous API for use in threaded applications. 
Name:       libsoup
Version:    2.42.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib-networking
Requires:  libxml2
Requires:  sqlite
Requires:  gobject-introspection
Source0:    http://ftp.gnome.org/pub/gnome/sources/libsoup/2.42/libsoup-2.42.2.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/libsoup/2.42/libsoup-2.42.2.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/libsoup/2.42
%description
 The libsoup is HTTP client/server library for GNOME. It uses GObject and the GLib main loop to integrate with GNOME applications and it also has asynchronous API for use in threaded applications. 
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
./configure --prefix=/usr --disable-static 
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
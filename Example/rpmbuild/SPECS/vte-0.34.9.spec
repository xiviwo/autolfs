%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The VTE package contains a termcap file implementation for terminal emulators. 
Name:       vte
Version:    0.34.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  gobject-introspection
Source0:    http://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.9.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.9.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/vte/0.34
%description
 The VTE package contains a termcap file implementation for terminal emulators. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-introspection &&
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
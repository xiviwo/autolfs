%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gtkmm package provides a C++ interface to GTK+ 2. It can be installed alongside Gtkmm-3.10.1 (the GTK+ 3 version) with no namespace conflicts. 
Name:       gtkmm
Version:    2.24.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  atkmm
Requires:  gtk
Requires:  pangomm
Source0:    http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.4.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.4.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24
%description
 The Gtkmm package provides a C++ interface to GTK+ 2. It can be installed alongside Gtkmm-3.10.1 (the GTK+ 3 version) with no namespace conflicts. 
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
./configure --prefix=/usr &&
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libxklavier package contains a utility library for X keyboard. 
Name:       libxklavier
Version:    5.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  iso-codes
Requires:  libxml2
Requires:  xorg-libraries
Requires:  gobject-introspection
Source0:    http://ftp.gnome.org/pub/gnome/sources/libxklavier/5.3/libxklavier-5.3.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/libxklavier/5.3/libxklavier-5.3.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/libxklavier/5.3
%description
 The libxklavier package contains a utility library for X keyboard. 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libXau package contains a library implementing the X11 Authorization Protocol. This is useful for restricting client access to the display. 
Name:       libxau
Version:    1.0.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-protocol-headers
Source0:    http://xorg.freedesktop.org/releases/individual/lib/libXau-1.0.8.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/lib/libXau-1.0.8.tar.bz2
URL:        http://xorg.freedesktop.org/releases/individual/lib
%description
 The libXau package contains a library implementing the X11 Authorization Protocol. This is useful for restricting client access to the display. 
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
./configure $XORG_CONFIG &&
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
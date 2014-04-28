%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The xcb-util package provides additional extensions to the XCB library, many that were previously found in Xlib, but are not part of core X protocol. 
Name:       xcb-util
Version:    0.3.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxcb
Source0:    http://xcb.freedesktop.org/dist/xcb-util-0.3.9.tar.bz2
URL:        http://xcb.freedesktop.org/dist
%description
 The xcb-util package provides additional extensions to the XCB library, many that were previously found in Xlib, but are not part of core X protocol. 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The util-macros package contains the m4 macros used by all of the Xorg packages. 
Name:       util-macros
Version:    1.18.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  introduction-to-xorg
Source0:    http://xorg.freedesktop.org/releases/individual/util/util-macros-1.18.0.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/util/util-macros-1.18.0.tar.bz2
URL:        http://xorg.freedesktop.org/releases/individual/util
%description
 The util-macros package contains the m4 macros used by all of the Xorg packages. 
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
./configure $XORG_CONFIG

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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     xdg-utils is a a set of command line tools that assist applications with a variety of desktop integration tasks. It is required for Linux Standards Base (LSB) conformance. 
Name:       xdg-utils
Version:    rc1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://portland.freedesktop.org/download/xdg-utils-1.1.0-rc1.tar.gz
URL:        http://portland.freedesktop.org/download
%description
 xdg-utils is a a set of command line tools that assist applications with a variety of desktop integration tasks. It is required for Linux Standards Base (LSB) conformance. 
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
./configure --prefix=/usr --mandir=/usr/share/man

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
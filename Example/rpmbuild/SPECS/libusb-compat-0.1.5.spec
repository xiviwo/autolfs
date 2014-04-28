%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libusb-compat package aims to look, feel and behave exactly like libusb-0.1. It is a compatibility layer needed by packages that have not been upgraded to the libusb-1.0 API. 
Name:       libusb-compat
Version:    0.1.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libusb
Source0:    http://downloads.sourceforge.net/libusb/libusb-compat-0.1.5.tar.bz2
URL:        http://downloads.sourceforge.net/libusb
%description
 The libusb-compat package aims to look, feel and behave exactly like libusb-0.1. It is a compatibility layer needed by packages that have not been upgraded to the libusb-1.0 API. 
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
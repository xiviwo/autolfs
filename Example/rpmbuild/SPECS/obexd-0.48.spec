%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Obexd package contains D-Bus services providing OBEX client and server functionality. OBEX is a communications protocol that facilitates the exchange of binary objects between devices. 
Name:       obexd
Version:    0.48
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  bluez
Requires:  libical
Source0:    http://www.kernel.org/pub/linux/bluetooth/obexd-0.48.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/bluetooth/obexd-0.48.tar.xz
URL:        http://www.kernel.org/pub/linux/bluetooth
%description
 The Obexd package contains D-Bus services providing OBEX client and server functionality. OBEX is a communications protocol that facilitates the exchange of binary objects between devices. 
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
sed -i 's/#include <string.h>/&\n#include <stdio.h>/' plugins/mas.c 
./configure --prefix=/usr --libexecdir=/usr/lib/obex 
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
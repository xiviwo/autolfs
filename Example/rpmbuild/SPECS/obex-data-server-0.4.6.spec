%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     OBEX Data Server package contains D-Bus service providing high-level OBEX client and server side functionality. 
Name:       obex-data-server
Version:    0.4.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  bluez
Requires:  dbus-glib
Requires:  imagemagick
Requires:  libusb-compat
Requires:  openobex
Source0:    http://tadas.dailyda.com/software/obex-data-server-0.4.6.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/obex-data-server-0.4.6-build-fixes-1.patch
URL:        http://tadas.dailyda.com/software
%description
 OBEX Data Server package contains D-Bus service providing high-level OBEX client and server side functionality. 
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
patch -Np1 -i %_sourcedir/obex-data-server-0.4.6-build-fixes-1.patch &&
./configure --prefix=/usr --sysconfdir=/etc &&
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
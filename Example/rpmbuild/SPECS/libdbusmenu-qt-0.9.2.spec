%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This library provides a Qt implementation of the DBusMenu specs, which goal is to expose menus on DBus. 
Name:       libdbusmenu-qt
Version:    0.9.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  qt
Source0:    http://launchpad.net/libdbusmenu-qt/trunk/0.9.2/+download/libdbusmenu-qt-0.9.2.tar.bz2
URL:        http://launchpad.net/libdbusmenu-qt/trunk/0.9.2/+download
%description
 This library provides a Qt implementation of the DBusMenu specs, which goal is to expose menus on DBus. 
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
mkdir -pv build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -DCMAKE_BUILD_TYPE=Release -DWITH_DOC=OFF .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build &&


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
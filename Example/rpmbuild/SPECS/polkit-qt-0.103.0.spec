%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Polkit-Qt provides an API to polkit in the Qt environment. 
Name:       polkit-qt
Version:    0.103.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  automoc4
Requires:  polkit
Source0:    http://download.kde.org/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2
Source1:    ftp://ftp.kde.org/pub/kde/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2
URL:        http://download.kde.org/stable/apps/KDE4.x/admin
%description
 Polkit-Qt provides an API to polkit in the Qt environment. 
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
cd    build &&
CMAKE_PREFIX_PATH=$QTDIR cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -Wno-dev .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&


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
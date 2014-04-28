%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Amarok is a powerful audio player for the KDE environment. Features include a context browser, integration with many online music services and support for management of several digital music players including Apple's iPod. 
Name:       amarok
Version:    2.8.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  kdelibs
Requires:  mariadb
Requires:  taglib
Requires:  ffmpeg
Requires:  nepomuk-core
Source0:    http://download.kde.org/stable/amarok/2.8.0/src/amarok-2.8.0.tar.bz2
Source1:    ftp://ftp.kde.org/pub/kde/stable/amarok/2.8.0/src/amarok-2.8.0.tar.bz2
URL:        http://download.kde.org/stable/amarok/2.8.0/src
%description
 Amarok is a powerful audio player for the KDE environment. Features include a context browser, integration with many online music services and support for management of several digital music players including Apple's iPod. 
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
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_BUILD_TYPE=Release -DKDE4_BUILD_TESTS=OFF -Wno-dev .. &&
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
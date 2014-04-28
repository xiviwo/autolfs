%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Oxygen theme is a photo-realistic icon style, with a high standard of graphics quality. 
Name:       oxygen-icons
Version:    4.12.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Source0:    http://download.kde.org/stable/4.12.2/src/oxygen-icons-4.12.2.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/oxygen-icons-4.12.2.tar.xz
URL:        http://download.kde.org/stable/4.12.2/src
%description
 The Oxygen theme is a photo-realistic icon style, with a high standard of graphics quality. 
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
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -Wno-dev ..

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
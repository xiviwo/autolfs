%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package provides a Phonon backend which utilizes the VLC media framework. 
Name:       phonon-backend-vlc
Version:    0.6.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  phonon
Requires:  vlc
Source0:    http://download.kde.org/stable/phonon/phonon-backend-vlc/0.6.2/phonon-backend-vlc-0.6.2.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/phonon/phonon-backend-vlc/0.6.2/phonon-backend-vlc-0.6.2.tar.xz
URL:        http://download.kde.org/stable/phonon/phonon-backend-vlc/0.6.2
%description
 This package provides a Phonon backend which utilizes the VLC media framework. 
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
mkdir -pv build 
cd    build 
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_BUILD_TYPE=Release .. 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build 


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
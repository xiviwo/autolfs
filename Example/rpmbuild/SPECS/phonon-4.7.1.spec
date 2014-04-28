%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Phonon is the multimedia API for KDE4. It replaces the old aRts, that is no longer supported by KDE. Phonon needs either the GStreamer or VLC backend. 
Name:       phonon
Version:    4.7.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  automoc4
Requires:  glib
Source0:    http://download.kde.org/stable/phonon/4.7.1/phonon-4.7.1.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/phonon/4.7.1/phonon-4.7.1.tar.xz
URL:        http://download.kde.org/stable/phonon/4.7.1
%description
 Phonon is the multimedia API for KDE4. It replaces the old aRts, that is no longer supported by KDE. Phonon needs either the GStreamer or VLC backend. 
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
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib -DPHONON_INSTALL_QT_EXTENSIONS_INTO_SYSTEM_QT=TRUE -DDBUS_INTERFACES_INSTALL_DIR=/usr/share/dbus-1/interfaces -Wno-dev .. &&
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
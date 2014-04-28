%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Audacious is a GTK+ based audio player. 
Name:       audacious
Version:    3.4.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  libxml2
Requires:  introduction-to-xorg
Requires:  x-window-system-environment
Source0:    http://distfiles.audacious-media-player.org/audacious-3.4.3.tar.bz2
Source1:    http://distfiles.audacious-media-player.org/audacious-plugins-3.4.3.tar.bz2
URL:        http://distfiles.audacious-media-player.org
%description
 Audacious is a GTK+ based audio player. 
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
TPUT=/bin/true ./configure --prefix=/usr --with-buildstamp="BLFS" &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 

TPUT=${RPM_BUILD_ROOT}/bin/true ./configure --prefix=${RPM_BUILD_ROOT}/usr &&
make
make install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
gtk-update-icon-cache &&

update-desktop-database
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
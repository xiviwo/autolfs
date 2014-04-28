%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     GeoClue is a modular geoinformation service built on top of the D-Bus messaging system. The goal of the GeoClue project is to make creating location-aware applications as simple as possible. 
Name:       geoclue
Version:    0.12.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  dbus-glib
Requires:  gconf
Requires:  libxslt
Requires:  libsoup
Requires:  networkmanager
Source0:    https://launchpad.net/geoclue/trunk/0.12/+download/geoclue-0.12.0.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/geoclue-0.12.0-gpsd_fix-1.patch
URL:        https://launchpad.net/geoclue/trunk/0.12/+download
%description
 GeoClue is a modular geoinformation service built on top of the D-Bus messaging system. The goal of the GeoClue project is to make creating location-aware applications as simple as possible. 
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
patch -Np1 -i %_sourcedir/geoclue-0.12.0-gpsd_fix-1.patch &&
sed -i "s@ -Werror@@" configure &&
sed -i "s@libnm_glib@libnm-glib@g" configure &&
sed -i "s@geoclue/libgeoclue.la@& -lgthread-2.0@g" providers/skyhook/Makefile.in &&
./configure --prefix=/usr &&
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
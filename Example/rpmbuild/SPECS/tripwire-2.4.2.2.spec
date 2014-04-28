%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Tripwire package contains programs used to verify the integrity of the files on a given system. 
Name:       tripwire
Version:    2.4.2.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://downloads.sourceforge.net/tripwire/tripwire-2.4.2.2-src.tar.bz2
URL:        http://downloads.sourceforge.net/tripwire
%description
 The Tripwire package contains programs used to verify the integrity of the files on a given system. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc/tripwire
sed -i -e 's@TWDB="${prefix}@TWDB="/var@' install/install.cfg            &&
sed -i -e 's/!Equal/!this->Equal/' src/cryptlib/algebra.h                &&
sed -i -e '/stdtwadmin.h/i#include <unistd.h>' src/twadmin/twadmincl.cpp &&
sed -i -e '/TWMAN/ s|${prefix}|/usr/share|' -e '/TWDOCS/s|${prefix}|/usr/share|' install/install.cfg          &&
./configure --prefix=${RPM_BUILD_ROOT}/usr --sysconfdir=${RPM_BUILD_ROOT}/etc/tripwire                     &&
make
make install && DESTDIR=${RPM_BUILD_ROOT} 

cp -v policy/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/tripwire


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
twadmin --create-polfile --site-keyfile /etc/tripwire/site.key /etc/tripwire/twpol.txt &&

tripwire --init

tripwire --check > /etc/tripwire/report.txt

twadmin --create-polfile /etc/tripwire/twpol.txt &&

tripwire --init
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
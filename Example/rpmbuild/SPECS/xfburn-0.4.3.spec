%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Xfburn is a GTK+ 2 GUI frontend for Libisoburn. This is useful for creating CDs and DVDs from files on your computer or ISO images downloaded from elsewhere. 
Name:       xfburn
Version:    0.4.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  exo
Requires:  libxfcegui4
Requires:  libisoburn
Source0:    http://archive.xfce.org/src/apps/xfburn/0.4/xfburn-0.4.3.tar.bz2
URL:        http://archive.xfce.org/src/apps/xfburn/0.4
%description
 Xfburn is a GTK+ 2 GUI frontend for Libisoburn. This is useful for creating CDs and DVDs from files on your computer or ISO images downloaded from elsewhere. 
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
sed -i '/<glib.h>/a#include <glib-object.h>' xfburn/xfburn-settings.h &&
./configure --prefix=/usr --disable-static &&
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
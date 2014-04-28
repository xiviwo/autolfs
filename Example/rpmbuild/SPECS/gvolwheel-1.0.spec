%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gvolwheel package provides a lightweight volume control with a tray icon. 
Name:       gvolwheel
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-utils
Requires:  gtk
Requires:  intltool
Requires:  xml-parser
Source0:    http://downloads.sourceforge.net/gvolwheel/gvolwheel-1.0.tar.gz
URL:        http://downloads.sourceforge.net/gvolwheel
%description
 The Gvolwheel package provides a lightweight volume control with a tray icon. 
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
sed -i 's%doc/gvolwheel%share/doc/gvolwheel-1.0%' Makefile.in 
./configure --prefix=/usr --enable-oss 
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
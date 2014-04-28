%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Thunar Volume Manager is an extension for the Thunar file manager, which enables automatic management of removable drives and media. 
Name:       thunar-volman
Version:    0.8.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  exo
Requires:  libxfce4ui
Requires:  udev-extras-from-systemd
Requires:  libnotify
Requires:  startup-notification
Source0:    http://archive.xfce.org/src/xfce/thunar-volman/0.8/thunar-volman-0.8.0.tar.bz2
URL:        http://archive.xfce.org/src/xfce/thunar-volman/0.8
%description
 The Thunar Volume Manager is an extension for the Thunar file manager, which enables automatic management of removable drives and media. 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Thunar is the Xfce file manager, a GTK+ 2 GUI to organise the files on your computer. 
Name:       thunar
Version:    1.6.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  exo
Requires:  libxfce4ui
Requires:  libnotify
Requires:  startup-notification
Requires:  udev-extras-from-systemd
Requires:  xfce4-panel
Source0:    http://archive.xfce.org/src/xfce/thunar/1.6/Thunar-1.6.3.tar.bz2
URL:        http://archive.xfce.org/src/xfce/thunar/1.6
%description
 Thunar is the Xfce file manager, a GTK+ 2 GUI to organise the files on your computer. 
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
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/Thunar-1.6.3 &&
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
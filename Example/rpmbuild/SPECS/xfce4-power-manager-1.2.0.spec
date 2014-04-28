%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xfce4 Power Manager is a power manager for the Xfce desktop, Xfce power manager manages the power sources on the computer and the devices that can be controlled to reduce their power consumption (such as LCD brightness level, monitor sleep, CPU frequency scaling). In addition, Xfce4 Power Manager provides a set of freedesktop-compliant DBus interfaces to inform other applications about current power level so that they can adjust their power consumption. 
Name:       xfce4-power-manager
Version:    1.2.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libnotify
Requires:  upower
Requires:  xfce4-panel
Source0:    http://archive.xfce.org/src/xfce/xfce4-power-manager/1.2/xfce4-power-manager-1.2.0.tar.bz2
URL:        http://archive.xfce.org/src/xfce/xfce4-power-manager/1.2
%description
 The Xfce4 Power Manager is a power manager for the Xfce desktop, Xfce power manager manages the power sources on the computer and the devices that can be controlled to reduce their power consumption (such as LCD brightness level, monitor sleep, CPU frequency scaling). In addition, Xfce4 Power Manager provides a set of freedesktop-compliant DBus interfaces to inform other applications about current power level so that they can adjust their power consumption. 
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
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docdir=${RPM_BUILD_ROOT}/usr/share/doc/xfce4-power-manager-1.2.0 imagesdir=${RPM_BUILD_ROOT}/usr/share/doc/xfce4-power-manager-1.2.0/images install DESTDIR=${RPM_BUILD_ROOT} 


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
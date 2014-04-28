%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xfce4 Notification Daemon is a small program that implements the "server-side" portion of the Freedesktop desktop notifications specification. Applications that wish to pop up a notification bubble in a standard way can use Xfce4-Notifyd to do so by sending standard messages over D-Bus using the org.freedesktop.Notifications interface. 
Name:       xfce4-notifyd
Version:    0.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libnotify
Requires:  libxfce4ui
Source0:    http://archive.xfce.org/src/apps/xfce4-notifyd/0.2/xfce4-notifyd-0.2.4.tar.bz2
URL:        http://archive.xfce.org/src/apps/xfce4-notifyd/0.2
%description
 The Xfce4 Notification Daemon is a small program that implements the "server-side" portion of the Freedesktop desktop notifications specification. Applications that wish to pop up a notification bubble in a standard way can use Xfce4-Notifyd to do so by sending standard messages over D-Bus using the org.freedesktop.Notifications interface. 
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

notify-send -i info Information "Hi ${USER}, This is a Test"

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
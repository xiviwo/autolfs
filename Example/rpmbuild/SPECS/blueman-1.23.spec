%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Blueman is full featured GTK+ Bluetooth manager. 
Name:       blueman
Version:    1.23
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  bluez
Requires:  d-bus-python
Requires:  gtk
Requires:  notify-python
Requires:  pygtk
Requires:  gtk
Requires:  pyrex
Requires:  startup-notification
Requires:  polkit
Requires:  obex-data-server
Requires:  polkit-gnome
Source0:    http://download.tuxfamily.org/blueman/blueman-1.23.tar.gz
URL:        http://download.tuxfamily.org/blueman
%description
 Blueman is full featured GTK+ Bluetooth manager. 
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
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/blueman --disable-static 
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
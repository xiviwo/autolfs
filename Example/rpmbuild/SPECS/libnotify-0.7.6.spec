%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libnotify library is used to send desktop notifications to a notification daemon, as defined in the Desktop Notifications spec. These notifications can be used to inform the user about an event or display some form of information without getting in the user's way. 
Name:       libnotify
Version:    0.7.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  notification-daemon
Source0:    http://ftp.gnome.org/pub/gnome/sources/libnotify/0.7/libnotify-0.7.6.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/libnotify/0.7/libnotify-0.7.6.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/libnotify/0.7
%description
 The libnotify library is used to send desktop notifications to a notification daemon, as defined in the Desktop Notifications spec. These notifications can be used to inform the user about an event or display some form of information without getting in the user's way. 
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
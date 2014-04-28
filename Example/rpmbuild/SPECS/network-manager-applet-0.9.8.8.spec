%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The NetworkManager Applet provides a tool and a panel applet used to configure wired and wireless network connections through GUI. It's designed for use with any desktop environment that uses GTK+ like Xfce and LXDE. 
Name:       network-manager-applet
Version:    0.9.8.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  iso-codes
Requires:  libsecret
Requires:  libnotify
Requires:  networkmanager
Requires:  gobject-introspection
Requires:  lxpolkit
Source0:    http://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.8.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.8.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9
%description
 The NetworkManager Applet provides a tool and a panel applet used to configure wired and wireless network connections through GUI. It's designed for use with any desktop environment that uses GTK+ like Xfce and LXDE. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-migration --disable-static &&
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GNOME Power Manager package contains a tool used to report on power management on the system. 
Name:       gnome-power-manager
Version:    3.10.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  upower
Source0:    http://ftp.gnome.org/pub/gnome/sources/gnome-power-manager/3.10/gnome-power-manager-3.10.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gnome-power-manager/3.10/gnome-power-manager-3.10.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gnome-power-manager/3.10
%description
 The GNOME Power Manager package contains a tool used to report on power management on the system. 
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
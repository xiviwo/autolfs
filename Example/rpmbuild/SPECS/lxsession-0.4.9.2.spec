%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The LXSession package contains the default session manager for LXDE. 
Name:       lxsession
Version:    0.4.9.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  dbus-glib
Requires:  gtk
Requires:  libgee
Requires:  lsb-release
Requires:  polkit
Requires:  vala
Source0:    http://downloads.sourceforge.net/lxde/lxsession-0.4.9.2.tar.gz
URL:        http://downloads.sourceforge.net/lxde
%description
 The LXSession package contains the default session manager for LXDE. 
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
./configure --prefix=/usr --disable-man &&
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
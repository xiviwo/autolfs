%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xfce4 Panel package contains the Xfce4 Panel. 
Name:       xfce4-panel
Version:    4.10.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  exo
Requires:  garcon
Requires:  libwnck
Requires:  libxfce4ui
Source0:    http://archive.xfce.org/src/xfce/xfce4-panel/4.10/xfce4-panel-4.10.1.tar.bz2
URL:        http://archive.xfce.org/src/xfce/xfce4-panel/4.10
%description
 The Xfce4 Panel package contains the Xfce4 Panel. 
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
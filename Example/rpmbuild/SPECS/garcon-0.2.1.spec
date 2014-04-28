%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Garcon package contains a freedesktop.org compliant menu implementation based on GLib and GIO. 
Name:       garcon
Version:    0.2.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxfce4util
Source0:    http://archive.xfce.org/src/xfce/garcon/0.2/garcon-0.2.1.tar.bz2
URL:        http://archive.xfce.org/src/xfce/garcon/0.2
%description
 The Garcon package contains a freedesktop.org compliant menu implementation based on GLib and GIO. 
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
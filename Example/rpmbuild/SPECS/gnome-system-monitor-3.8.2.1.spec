%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GNOME System Monitor package contains GNOME's replacement for gtop. 
Name:       gnome-system-monitor
Version:    3.8.2.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gnome-icon-theme
Requires:  gtkmm
Requires:  libgtop
Requires:  librsvg
Requires:  libwnck
Requires:  yelp-xsl
Source0:    http://ftp.gnome.org/pub/gnome/sources/gnome-system-monitor/3.8/gnome-system-monitor-3.8.2.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gnome-system-monitor/3.8/gnome-system-monitor-3.8.2.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gnome-system-monitor/3.8
%description
 The GNOME System Monitor package contains GNOME's replacement for gtop. 
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
./configure --prefix=/usr --libexecdir=/usr/lib 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Midori is a lightweight web browser that uses WebKitGTK+. 
Name:       midori
Version:    0.5.5
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libzeitgeist
Requires:  webkitgtk
Requires:  vala
Requires:  libnotify
Requires:  librsvg
Source0:    http://www.midori-browser.org/downloads/midori_0.5.5_all_.tar.bz2
URL:        http://www.midori-browser.org/downloads
%description
 Midori is a lightweight web browser that uses WebKitGTK+. 
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
./configure --prefix=/usr --docdir=/usr/share/doc/midori-0.5.5 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Balsa package contains a GNOME-2 based mail client. 
Name:       balsa
Version:    2.5.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  enchant
Requires:  gmime
Requires:  libesmtp
Requires:  rarian
Requires:  aspell
Source0:    http://pawsa.fedorapeople.org/balsa/balsa-2.5.1.tar.bz2
URL:        http://pawsa.fedorapeople.org/balsa
%description
 The Balsa package contains a GNOME-2 based mail client. 
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
sed -i "/(HAVE_CONFIG_H)/i #include <glib-2.0/glib.h>" src/main-window.c &&
./configure --prefix=/usr --sysconfdir=/etc/gnome --localstatedir=/var/lib --with-rubrica --without-html-widget --without-libnotify --without-nm --without-gtkspell       &&
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
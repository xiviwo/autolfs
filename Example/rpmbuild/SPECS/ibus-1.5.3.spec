%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     IBus is an Intelligent Input Bus. It is a new input framework for Linux OS. It provides full featured and user friendly input method user interface. 
Name:       ibus
Version:    1.5.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  dconf
Requires:  iso-codes
Requires:  gobject-introspection
Requires:  gtk
Requires:  vala
Source0:    http://ibus.googlecode.com/files/ibus-1.5.3.tar.gz
URL:        http://ibus.googlecode.com/files
%description
 IBus is an Intelligent Input Bus. It is a new input framework for Linux OS. It provides full featured and user friendly input method user interface. 
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
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/ibus 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Brasero is an application used to burn CD/DVD on the GNOME Desktop. It is designed to be as simple as possible and has some unique features that enable users to create their discs easily and quickly. 
Name:       brasero
Version:    3.8.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  libcanberra
Requires:  libnotify
Requires:  yelp-xsl
Requires:  gobject-introspection
Requires:  libburn
Requires:  libisofs
Requires:  nautilus
Requires:  totem-pl-parser
Requires:  dvd-rw-tools
Requires:  gvfs
Source0:    http://ftp.gnome.org/pub/gnome/sources/brasero/3.8/brasero-3.8.0.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/brasero/3.8/brasero-3.8.0.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/brasero/3.8
%description
 Brasero is an application used to burn CD/DVD on the GNOME Desktop. It is designed to be as simple as possible and has some unique features that enable users to create their discs easily and quickly. 
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
./configure --prefix=/usr 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Cheese is used to take photos and videos with fun graphical effects. 
Name:       cheese
Version:    3.10.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  clutter-gst
Requires:  clutter-gtk
Requires:  gnome-desktop
Requires:  gnome-video-effects
Requires:  gst-plugins-bad
Requires:  gst-plugins-good
Requires:  libcanberra
Requires:  librsvg
Requires:  udev-extras-from-systemd
Requires:  yelp-xsl
Requires:  gobject-introspection
Requires:  vala
Source0:    http://ftp.gnome.org/pub/gnome/sources/cheese/3.10/cheese-3.10.2.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/cheese/3.10/cheese-3.10.2.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/cheese/3.10
%description
 Cheese is used to take photos and videos with fun graphical effects. 
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
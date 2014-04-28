%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gcr package contains libraries used for displaying certificates and accessing key stores. It also provides the viewer for crypto files on the GNOME Desktop. 
Name:       gcr
Version:    3.9.91
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  intltool
Requires:  libgcrypt
Requires:  libtasn1
Requires:  p11-kit
Requires:  gnupg
Requires:  gobject-introspection
Requires:  gtk
Source0:    http://ftp.gnome.org/pub/gnome/sources/gcr/3.9/gcr-3.9.91.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gcr/3.9/gcr-3.9.91.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gcr/3.9
%description
 The Gcr package contains libraries used for displaying certificates and accessing key stores. It also provides the viewer for crypto files on the GNOME Desktop. 
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
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/gnome-keyring 
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
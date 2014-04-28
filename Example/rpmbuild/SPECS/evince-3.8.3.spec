%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Evince is a document viewer for multiple document formats. It supports PDF, Postscript, DjVu, TIFF and DVI. It is useful for viewing documents of various types using one simple application instead of the multiple document viewers that once existed on the GNOME Desktop. 
Name:       evince
Version:    3.8.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gnome-icon-theme
Requires:  gsettings-desktop-schemas
Requires:  gtk
Requires:  yelp-xsl
Requires:  gobject-introspection
Requires:  libsecret
Requires:  nautilus
Requires:  poppler
Source0:    http://ftp.gnome.org/pub/gnome/sources/evince/3.8/evince-3.8.3.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/evince/3.8/evince-3.8.3.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/evince/3.8
%description
 Evince is a document viewer for multiple document formats. It supports PDF, Postscript, DjVu, TIFF and DVI. It is useful for viewing documents of various types using one simple application instead of the multiple document viewers that once existed on the GNOME Desktop. 
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
./configure --prefix=/usr --libexecdir=/usr/lib/evince --enable-introspection --disable-static 
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
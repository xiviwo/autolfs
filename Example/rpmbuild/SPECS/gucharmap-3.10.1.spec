%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Gucharmap is a Unicode character map and font viewer. It allows you to browse through all the available Unicode characters and categories for the installed fonts, and to examine their detailed properties. It is an easy way to find the character you might only know by its Unicode name or code point. 
Name:       gucharmap
Version:    3.10.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  desktop-file-utils
Requires:  gtk
Requires:  yelp-xsl
Requires:  gobject-introspection
Requires:  vala
Source0:    http://ftp.gnome.org/pub/gnome/sources/gucharmap/3.10/gucharmap-3.10.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gucharmap/3.10/gucharmap-3.10.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gucharmap/3.10
%description
 Gucharmap is a Unicode character map and font viewer. It allows you to browse through all the available Unicode characters and categories for the installed fonts, and to examine their detailed properties. It is an easy way to find the character you might only know by its Unicode name or code point. 
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
./configure --prefix=/usr --enable-vala &&
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
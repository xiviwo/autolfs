%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Grilo-Plugins is a collection of plugins (Apple Trailers, Blip.tv, Bookmarks, Filesystem, Flickr, Jamendo, Magnatune, Rai.tv, Tracker, Youtube, between others) to make media discovery and browsing easy for applications that support Grilo framework, such as Totem (some plugins are disabled in Totem). 
Name:       grilo-plugins
Version:    0.2.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  grilo
Requires:  libgcrypt
Requires:  sqlite
Requires:  libsoup
Requires:  gobject-introspection
Requires:  totem-pl-parser
Source0:    http://ftp.gnome.org/pub/gnome/sources/grilo-plugins/0.2/grilo-plugins-0.2.10.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/grilo-plugins/0.2/grilo-plugins-0.2.10.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/grilo-plugins/0.2
%description
 Grilo-Plugins is a collection of plugins (Apple Trailers, Blip.tv, Bookmarks, Filesystem, Flickr, Jamendo, Magnatune, Rai.tv, Tracker, Youtube, between others) to make media discovery and browsing easy for applications that support Grilo framework, such as Totem (some plugins are disabled in Totem). 
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
./configure --prefix=/usr --disable-pocket &&
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
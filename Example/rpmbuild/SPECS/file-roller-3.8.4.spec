%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     File Roller is an archive manager for GNOME with support for tar, bzip2, gzip, zip, jar, compress, lzop and many other archive formats. 
Name:       file-roller
Version:    3.8.4
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  yelp-xsl
Requires:  json-glib
Requires:  libarchive
Requires:  libnotify
Requires:  nautilus
Source0:    http://ftp.gnome.org/pub/gnome/sources/file-roller/3.8/file-roller-3.8.4.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/file-roller/3.8/file-roller-3.8.4.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/file-roller/3.8
%description
 File Roller is an archive manager for GNOME with support for tar, bzip2, gzip, zip, jar, compress, lzop and many other archive formats. 
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
./configure --prefix=/usr --libexecdir=/usr/lib --disable-packagekit --disable-static 
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
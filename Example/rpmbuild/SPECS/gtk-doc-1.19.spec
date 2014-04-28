%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GTK-Doc package contains a code documenter. This is useful for extracting specially formatted comments from the code to create API documentation. This package is optional; if it is not installed, packages will not build the documentation. This does not mean that you will not have any documentation. If GTK-Doc is not available, the install process will copy any pre-built documentation to your system. 
Name:       gtk-doc
Version:    1.19
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  docbook-xml
Requires:  docbook-xsl
Requires:  itstool
Requires:  libxslt
Source0:    http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.19/gtk-doc-1.19.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.19/gtk-doc-1.19.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.19
%description
 The GTK-Doc package contains a code documenter. This is useful for extracting specially formatted comments from the code to create API documentation. This package is optional; if it is not installed, packages will not build the documentation. This does not mean that you will not have any documentation. If GTK-Doc is not available, the install process will copy any pre-built documentation to your system. 
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
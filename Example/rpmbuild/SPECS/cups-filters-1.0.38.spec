%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The CUPS Filters package contains backends, filters and other software that was once part of the core CUPS distribution but is no longer maintained by Apple Inc. 
Name:       cups-filters
Version:    1.0.38
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  cups
Requires:  ijs
Requires:  little-cms
Requires:  poppler
Requires:  qpdf
Requires:  libjpeg-turbo
Requires:  libpng
Requires:  libtiff
Source0:    http://www.openprinting.org/download/cups-filters/cups-filters-1.0.38.tar.xz
URL:        http://www.openprinting.org/download/cups-filters
%description
 The CUPS Filters package contains backends, filters and other software that was once part of the core CUPS distribution but is no longer maintained by Apple Inc. 
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
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/cups-filters-1.0.38 --without-rcdir --with-gs-path=/usr/bin/gs --with-pdftops-path=/usr/bin/gs --disable-avahi --disable-static                            
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
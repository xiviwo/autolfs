%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gutenprint (formerly Gimp-Print) package contains high quality drivers for many brands and models of printers for use with ghostscript-9.10, Cups-1.7.1, Foomatic, and the GIMP-2.0. See a list of supported printers at http://gutenprint.sourceforge.net/p_Supported_Printers.php. 
Name:       gutenprint
Version:    5.2.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cups
Requires:  gimp
Source0:    http://downloads.sourceforge.net/gimp-print/gutenprint-5.2.9.tar.bz2
URL:        http://downloads.sourceforge.net/gimp-print
%description
 The Gutenprint (formerly Gimp-Print) package contains high quality drivers for many brands and models of printers for use with ghostscript-9.10, Cups-1.7.1, Foomatic, and the GIMP-2.0. See a list of supported printers at http://gutenprint.sourceforge.net/p_Supported_Printers.php. 
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
sed -i 's|$(PACKAGE)/doc|doc/$(PACKAGE)-$(VERSION)|' {,doc/,doc/developer/}Makefile.in &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gutenprint-5.2.9/api
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gutenprint-5.2.9/api/gutenprint{,ui2} &&

install -v -m644    doc/gutenprint/html/* ${RPM_BUILD_ROOT}/usr/share/doc/gutenprint-5.2.9/api/gutenprint &&

install -v -m644    doc/gutenprintui2/html/* ${RPM_BUILD_ROOT}/usr/share/doc/gutenprint-5.2.9/api/gutenprintui2


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/etc/rc.d/init.d/cups restart
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
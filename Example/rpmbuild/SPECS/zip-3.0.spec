%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Zip package contains Zip utilities. These are useful for compressing files into ZIP archives. 
Name:       zip
Version:    3.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/infozip/zip30.tar.gz
Source1:    ftp://ftp.info-zip.org/pub/infozip/src/zip30.tgz
URL:        http://downloads.sourceforge.net/infozip
%description
 The Zip package contains Zip utilities. These are useful for compressing files into ZIP archives. 
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
make -f unix/Makefile generic_gcc %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make prefix=${RPM_BUILD_ROOT}/usr MANDIR=${RPM_BUILD_ROOT}/usr/share/man/man1 -f unix/Makefile install DESTDIR=${RPM_BUILD_ROOT} 


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
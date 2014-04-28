%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The PCI Utils package contains a set of programs for listing PCI devices, inspecting their status and setting their configuration registers. 
Name:       pciutils
Version:    3.2.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.2.0.tar.xz
Source1:    ftp://ftp.kernel.org/pub/software/utils/pciutils/pciutils-3.2.0.tar.xz
URL:        http://ftp.kernel.org/pub/software/utils/pciutils
%description
 The PCI Utils package contains a set of programs for listing PCI devices, inspecting their status and setting their configuration registers. 
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
make PREFIX=/usr SHAREDIR=/usr/share/misc MANDIR=/usr/share/man SHARED=yes ZLIB=no all %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make PREFIX=${RPM_BUILD_ROOT}/usr SHAREDIR=${RPM_BUILD_ROOT}/usr/share/misc MANDIR=${RPM_BUILD_ROOT}/usr/share/man SHARED=yes ZLIB=no install install-lib       DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libpci.so.3.2.0
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
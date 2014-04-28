%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libcap package implements the user-space interfaces to the POSIX 1003.1e capabilities available in Linux kernels. These capabilities are a partitioning of the all powerful root privilege into a set of distinct privileges. 
Name:       libcap
Version:    2.24
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  attr
Source0:    https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.24.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.24.tar.xz
URL:        https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2
%description
 The libcap package implements the user-space interfaces to the POSIX 1003.1e capabilities available in Linux kernels. These capabilities are a partitioning of the all powerful root privilege into a set of distinct privileges. 
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
sed -i 's:LIBDIR:PAM_&:g' pam_cap/Makefile &&
make %{?_smp_mflags} 
sed -i '/install.*STALIBNAME/ s/^/#/' libcap/Makefile

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make prefix=${RPM_BUILD_ROOT}/usr SBINDIR=${RPM_BUILD_ROOT}/sbin PAM_LIBDIR=${RPM_BUILD_ROOT}/lib RAISE_SETFCAP=no install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libcap.so.* ${RPM_BUILD_ROOT}/lib &&

ln -sfv ../../lib/libcap.so.2 ${RPM_BUILD_ROOT}/usr/lib/libcap.so


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libcap.so &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Linux API Headers (in linux-3.13.3.tar.xz) expose the kernel's API for use by Glibc. 
Name:       linux-API-header
Version:    3.13.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.13.3.tar.xz

URL:        http://www.kernel.org/pub/linux/kernel/v3.x
%description
 The Linux API Headers (in linux-3.13.3.tar.xz) expose the kernel's API for use by Glibc. 
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
make mrproper %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/include
make headers_check
make INSTALL_HDR_PATH=dest headers_install DESTDIR=${RPM_BUILD_ROOT} 

find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* ${RPM_BUILD_ROOT}/usr/include


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
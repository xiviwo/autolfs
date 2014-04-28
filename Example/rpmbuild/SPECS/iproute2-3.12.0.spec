%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The IPRoute2 package contains programs for basic and advanced IPV4-based networking. 
Name:       iproute2
Version:    3.12.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.12.0.tar.xz

URL:        http://www.kernel.org/pub/linux/utils/net/iproute2
%description
 The IPRoute2 package contains programs for basic and advanced IPV4-based networking. 
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
sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
make DESTDIR= %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make DESTDIR=${RPM_BUILD_ROOT} MANDIR=${RPM_BUILD_ROOT}/usr/share/man DOCDIR=${RPM_BUILD_ROOT}/usr/share/doc/iproute2-3.12.0 install DESTDIR=${RPM_BUILD_ROOT} 


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
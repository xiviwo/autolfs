%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The lm_sensors package provides user-space support for the hardware monitoring drivers in the Linux kernel. This is useful for monitoring the temperature of the CPU and adjusting the performance of some hardware (such as cooling fans). 
Name:       lm-sensors
Version:    3.3.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  which
Source0:    http://dl.lm-sensors.org/lm-sensors/releases/lm_sensors-3.3.5.tar.bz2
Source1:    ftp://ftp.netroedge.com/pub/lm-sensors/lm_sensors-3.3.5.tar.bz2
URL:        http://dl.lm-sensors.org/lm-sensors/releases
%description
 The lm_sensors package provides user-space support for the hardware monitoring drivers in the Linux kernel. This is useful for monitoring the temperature of the CPU and adjusting the performance of some hardware (such as cooling fans). 
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
make PREFIX=/usr BUILD_STATIC_LIB=0 MANDIR=/usr/share/man %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make PREFIX=${RPM_BUILD_ROOT}/usr BUILD_STATIC_LIB=0 MANDIR=${RPM_BUILD_ROOT}/usr/share/man install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/lm_sensors-3.3.5 &&

cp -rv              README INSTALL doc/* ${RPM_BUILD_ROOT}/usr/share/doc/lm_sensors-3.3.5

sensors-detect

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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Wireless Extension (WE) is a generic API in the Linux kernel allowing a driver to expose configuration and statistics specific to common Wireless LANs to user space. A single set of tools can support all the variations of Wireless LANs, regardless of their type as long as the driver supports Wireless Extensions. WE parameters may also be changed on the fly without restarting the driver (or Linux). 
Name:       wireless-tools
Version:    29
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.29.tar.gz
URL:        http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux
%description
 The Wireless Extension (WE) is a generic API in the Linux kernel allowing a driver to expose configuration and statistics specific to common Wireless LANs to user space. A single set of tools can support all the variations of Wireless LANs, regardless of their type as long as the driver supports Wireless Extensions. WE parameters may also be changed on the fly without restarting the driver (or Linux). 
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
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make PREFIX=${RPM_BUILD_ROOT}/usr INSTALL_MAN=${RPM_BUILD_ROOT}/usr/share/man install DESTDIR=${RPM_BUILD_ROOT} 


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
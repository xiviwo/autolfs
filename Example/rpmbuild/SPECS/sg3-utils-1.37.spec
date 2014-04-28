%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The sg3_utils package contains low level utilities for devices that use a SCSI command set. Apart from SCSI parallel interface (SPI) devices, the SCSI command set is used by ATAPI devices (CD/DVDs and tapes), USB mass storage devices, Fibre Channel disks, IEEE 1394 storage devices (that use the "SBP" protocol), SAS, iSCSI and FCoE devices (amongst others). 
Name:       sg3-utils
Version:    1.37
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sg.danny.cz/sg/p/sg3_utils-1.37.tar.xz
URL:        http://sg.danny.cz/sg/p
%description
 The sg3_utils package contains low level utilities for devices that use a SCSI command set. Apart from SCSI parallel interface (SPI) devices, the SCSI command set is used by ATAPI devices (CD/DVDs and tapes), USB mass storage devices, Fibre Channel disks, IEEE 1394 storage devices (that use the "SBP" protocol), SAS, iSCSI and FCoE devices (amongst others). 
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
./configure --prefix=/usr --disable-static &&
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
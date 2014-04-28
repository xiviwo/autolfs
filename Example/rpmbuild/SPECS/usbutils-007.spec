%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The USB Utils package contains an utility used to display information about USB buses in the system and the devices connected to them. 
Name:       usbutils
Version:    007
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libusb
Source0:    http://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz
URL:        http://ftp.kernel.org/pub/linux/utils/usb/usbutils
%description
 The USB Utils package contains an utility used to display information about USB buses in the system and the devices connected to them. 
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
./configure --prefix=/usr --disable-zlib --datadir=/usr/share/misc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
make install && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/sbin/update-usbids.sh ${RPM_BUILD_ROOT}/usr/sbin/update-usbids


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
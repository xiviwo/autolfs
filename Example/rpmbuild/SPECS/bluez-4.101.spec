%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The BlueZ package contains the Bluetooth protocol stack for Linux. 
Name:       bluez
Version:    4.101
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  d-bus
Requires:  glib
Source0:    http://www.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/bluetooth/bluez-4.101.tar.xz
URL:        http://www.kernel.org/pub/linux/bluetooth
%description
 The BlueZ package contains the Bluetooth protocol stack for Linux. 
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-bccmd --enable-dfutool --enable-dund --enable-hid2hci --enable-hidd --enable-pand --enable-tools --enable-wiimote --disable-test --without-systemdunitdir &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/bluetooth
make install DESTDIR=${RPM_BUILD_ROOT} 

for CONFFILE in audio input network serial ; do
    install -v -m644 ${CONFFILE}/${CONFFILE}.conf ${RPM_BUILD_ROOT}/etc/bluetooth/${CONFFILE}.conf

done
unset CONFFILE
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-bluetooth DESTDIR=${RPM_BUILD_ROOT} 


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
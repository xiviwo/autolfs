%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Linux package contains the Linux kernel. 
Name:       linux
Version:    3.10.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.10.10.tar.xz

URL:        http://www.kernel.org/pub/linux/kernel/v3.x
%description
 The Linux package contains the Linux kernel. 
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

make localmodconfig %{?_smp_mflags} 

make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/boot
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc/linux-3.10.10
mkdir -pv $RPM_BUILD_ROOT/etc/modprobe.d
make modules_install INSTALL_MOD_PATH=$RPM_BUILD_ROOT  DESTDIR=$RPM_BUILD_ROOT 

cp -v arch/x86/boot/bzImage ${RPM_BUILD_ROOT}/boot/vmlinuz-3.10.10-lfs-7.4

cp -v System.map ${RPM_BUILD_ROOT}/boot/System.map-3.10.10

cp -v .config ${RPM_BUILD_ROOT}/boot/config-3.10.10

install -d ${RPM_BUILD_ROOT}/usr/share/doc/linux-3.10.10

cp -r Documentation/* ${RPM_BUILD_ROOT}/usr/share/doc/linux-3.10.10

install -v -m755 -d ${RPM_BUILD_ROOT}/etc/modprobe.d

cat > ${RPM_BUILD_ROOT}/etc/modprobe.d/usb.conf << "EOF"

# Begin /etc/modprobe.d/usb.conf
install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
# End /etc/modprobe.d/usb.conf
EOF

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
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
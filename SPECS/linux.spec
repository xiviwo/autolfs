Name:           linux
Version:	3.8.1
Release:        1%{?dist}
Summary:	The Linux package contains the Linux kernel.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter08/kernel.html
Source0:        http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.8.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Linux package contains the Linux kernel.

%prep
%setup -q

%build
make mrproper %{?_smp_mflags}

make LANG=en_US.utf8 LC_ALL= menuconfig %{?_smp_mflags}

make %{?_smp_mflags}



%install
rm -rf $RPM_BUILD_ROOT

make modules_install INSTALL_MOD_PATH=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/boot
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
cp -v arch/x86/boot/bzImage $RPM_BUILD_ROOT/boot/vmlinuz-3.8.1-lfs-7.3
cp -v System.map $RPM_BUILD_ROOT/boot/System.map-3.8.1
cp -v .config $RPM_BUILD_ROOT/boot/config-3.8.1
install -d $RPM_BUILD_ROOT/usr/share/doc/linux-3.8.1

cp -r Documentation/* $RPM_BUILD_ROOT/usr/share/doc/linux-3.8.1

install -v -m755 -d $RPM_BUILD_ROOT/etc/modprobe.d
cat > $RPM_BUILD_ROOT/etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     qemu is a full virtualization solution for Linux on x86 hardware containing virtualization extensions (Intel VT or AMD-V). 
Name:       qemu
Version:    1.7.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  python
Requires:  sdl
Requires:  x-window-system-environment
Source0:    http://wiki.qemu.org/download/qemu-1.7.0.tar.bz2
URL:        http://wiki.qemu.org/download
%description
 qemu is a full virtualization solution for Linux on x86 hardware containing virtualization extensions (Intel VT or AMD-V). 
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
egrep '^flags.*(vmx|svm)' /proc/cpuinfo
export LIBRARY_PATH=/opt/xorg/lib
sed -e '/#include <sys\/capability.h>/ d' -e '/#include "virtio-9p-marshal.h"/ i#include <sys\/capability.h>' -i fsdev/virtfs-proxy-helper.c &&
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/qemu-1.7.0 --target-list=x86_64-softmmu &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib/udev/rules.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install && DESTDIR=${RPM_BUILD_ROOT} 

[ -e  ${RPM_BUILD_ROOT}/usr/lib/libcacard.so ] && chmod -v 755 ${RPM_BUILD_ROOT}/usr/lib/libcacard.so

cat > /lib/udev/rules.d/65-kvm.rules << "EOF"
KERNEL=="kvm", NAME="%k", GROUP="kvm", MODE="0660"
EOF
ln -svf qemu-system-x86_64 ${RPM_BUILD_ROOT}/usr/bin/qemu

cat > /etc/qemu-ifup << EOF
#!/bin/bash
switch=br0
if [ -n "\$1" ]; then
  # Add new tap0 interface to bridge
  /sbin/ip link set \$1 up
  sleep 0.5s
  /usr/sbin/brctl addif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi
exit 0
EOF
cat > /etc/qemu-ifdown << EOF
#!/bin/bash
switch=br0
if [ -n "\$1" ]; then
  # Remove tap0 interface from bridge
  /usr/sbin/brctl delif \$switch \$1
else
  echo "Error: no interface specified"
  exit 1
fi
exit 0
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
groupadd -g 61 kvm

usermod -a -G kvm mao

sysctl -w net.ipv4.ip_forward=1

cat >> /etc/sysctl.conf << EOF

net.ipv4.ip_forward=1

EOF

chmod +x /etc/qemu-ifup

chmod +x /etc/qemu-ifdown
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
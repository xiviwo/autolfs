%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The bridge-utils package contains a utility needed to create and manage bridge devices. This is useful in setting up networks for a hosted virtual machine (VM). 
Name:       bridge-utils
Version:    1.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/bridge-utils-1.5-linux_3.8_fix-1.patch
URL:        http://sourceforge.net/projects/bridge/files/bridge
%description
 The bridge-utils package contains a utility needed to create and manage bridge devices. This is useful in setting up networks for a hosted virtual machine (VM). 
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
patch -Np1 -i %_sourcedir/bridge-utils-1.5-linux_3.8_fix-1.patch &&
autoconf -o configure configure.in                      &&
./configure --prefix=/usr                               &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-service-bridge DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
cat > /etc/sysconfig/ifconfig.br0 << "EOF"
ONBOOT=yes
IFACE=br0
SERVICE="bridge ipv4-static"  # Space separated
IP=192.168.1.32
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
CHECK_LINK=no                 # Don't check before bridge is created
STP=no                        # Spanning tree protocol, default no
INTERFACE_COMPONENTS="eth0"   # Add to IFACE, space separated devices
IP_FORWARD=true
EOF

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
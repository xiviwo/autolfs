%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ISC DHCP package contains both the client and server programs for DHCP. dhclient (the client) is used for connecting to a network which uses DHCP to assign network addresses. dhcpd (the server) is used for assigning network addresses on private networks. 
Name:       dhcp
Version:    4.3.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.isc.org/isc/dhcp/4.3.0/dhcp-4.3.0.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/dhcp-4.3.0-client_script-1.patch
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/dhcp-4.3.0-missing_ipv6-1.patch
URL:        ftp://ftp.isc.org/isc/dhcp/4.3.0
%description
 The ISC DHCP package contains both the client and server programs for DHCP. dhclient (the client) is used for connecting to a network which uses DHCP to assign network addresses. dhcpd (the server) is used for assigning network addresses on private networks. 
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
patch -Np1 -i %_sourcedir/dhcp-4.3.0-missing_ipv6-1.patch
patch -Np1 -i %_sourcedir/dhcp-4.3.0-client_script-1.patch &&
CFLAGS="-D_PATH_DHCLIENT_SCRIPT='\"/sbin/dhclient-script\"' -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"' -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'" ./configure --prefix=/usr --sysconfdir=/etc/dhcp --localstatedir=/var --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases --with-cli-lease-file=/var/lib/dhclient/dhclient.leases --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/sbin
mkdir -pv ${RPM_BUILD_ROOT}/var/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
mkdir -pv ${RPM_BUILD_ROOT}/etc/dhcp
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make -C client install         && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/sbin/dhclient ${RPM_BUILD_ROOT}/sbin &&

install -v -m755 client/scripts/linux ${RPM_BUILD_ROOT}/sbin/dhclient-script

make -C server install DESTDIR=${RPM_BUILD_ROOT} 

make install                   && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/sbin/dhclient ${RPM_BUILD_ROOT}/sbin &&

install -v -m755 client/scripts/linux ${RPM_BUILD_ROOT}/sbin/dhclient-script

cat > /etc/dhcp/dhclient.conf << "EOF"
# Begin /etc/dhcp/dhclient.conf
#
# Basic dhclient.conf(5)
#prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        ntp-servers;
require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;
# End /etc/dhcp/dhclient.conf
EOF
install -v -dm 755 ${RPM_BUILD_ROOT}/var/lib/dhclient

dhclient <eth0>
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-service-dhclient DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhclient"
DHCP_START=""
DHCP_STOP=""
# Set PRINTIP="yes" to have the script print
# the DHCP assigned IP address
PRINTIP="no"
# Set PRINTALL="yes" to print the DHCP assigned values for
# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".
PRINTALL="no"
EOF
cat > /etc/dhcp/dhcpd.conf << "EOF"
# Begin /etc/dhcp/dhcpd.conf
#
# Example dhcpd.conf(5)
# Use this to enble / disable dynamic dns updates globally.
ddns-update-style none;
# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}
# End /etc/dhcp/dhcpd.conf
EOF
install -v -dm 755 ${RPM_BUILD_ROOT}/var/lib/dhcpd

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-dhcpd DESTDIR=${RPM_BUILD_ROOT} 


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
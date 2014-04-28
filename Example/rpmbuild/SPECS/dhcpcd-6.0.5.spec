%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     dhcpcd is an implementation of the DHCP client specified in RFC2131. A DHCP client is useful for connecting your computer to a network which uses DHCP to assign network addresses. dhcpcd strives to be a fully featured, yet very lightweight DHCP client. 
Name:       dhcpcd
Version:    6.0.5
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://roy.marples.name/downloads/dhcpcd/dhcpcd-6.0.5.tar.bz2
Source1:    ftp://ftp.osuosl.org/pub/gentoo/distfiles/dhcpcd-6.0.5.tar.bz2
URL:        http://roy.marples.name/downloads/dhcpcd
%description
 dhcpcd is an implementation of the DHCP client specified in RFC2131. A DHCP client is useful for connecting your computer to a network which uses DHCP to assign network addresses. dhcpcd strives to be a fully featured, yet very lightweight DHCP client. 
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
./configure --libexecdir=/lib/dhcpcd --dbdir=/run --sysconfdir=/etc 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/lib/dhcpcd/dhcpcd-hooks/
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make install DESTDIR=${RPM_BUILD_ROOT} 

sed -i "s;/var/lib;/run;g" dhcpcd-hooks/50-dhcpcd-compat 
install -v -m 644 dhcpcd-hooks/50-dhcpcd-compat ${RPM_BUILD_ROOT}/lib/dhcpcd/dhcpcd-hooks/

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-service-dhcpcd DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhcpcd"
DHCP_START="-b -q <insert appropriate start options here>"
DHCP_STOP="-k <insert additional stop options here>"
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
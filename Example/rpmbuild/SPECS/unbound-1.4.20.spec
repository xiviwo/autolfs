%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Unbound is a validating, recursive, and caching DNS resolver. It is designed as a set of modular components that incorporate modern features, such as enhanced security (DNSSEC) validation, Internet Protocol Version 6 (IPv6), and a client resolver library API as an integral part of the architecture. 
Name:       unbound
Version:    1.4.20
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  ldns
Requires:  openssl
Source0:    http://www.unbound.net/downloads/unbound-1.4.20.tar.gz
URL:        http://www.unbound.net/downloads
%description
 Unbound is a validating, recursive, and caching DNS resolver. It is designed as a set of modular components that incorporate modern features, such as enhanced security (DNSSEC) validation, Internet Protocol Version 6 (IPv6), and a client resolver library API as an integral part of the architecture. 
%pre
groupadd -g 88 unbound

useradd -c "Unbound DNS resolver" -d /var/lib/unbound -u 88 -g unbound -s /bin/false unbound
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
./configure --prefix=/usr --sysconfdir=/etc --disable-static --with-pidfile=/run/unbound.pid 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
mkdir -pv ${RPM_BUILD_ROOT}/etc/dhcp
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/
make install  DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/sbin/unbound-host ${RPM_BUILD_ROOT}/usr/bin

echo "nameserver 127.0.0.1" > ${RPM_BUILD_ROOT}/etc/resolv.conf

sed -i '/request ${RPM_BUILD_ROOT}/i\supersede domain-name-servers 127.0.0.1;' ${RPM_BUILD_ROOT}/etc/dhcp/dhclient.conf

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-unbound DESTDIR=${RPM_BUILD_ROOT} 


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
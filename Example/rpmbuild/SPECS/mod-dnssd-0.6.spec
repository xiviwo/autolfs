%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The mod_dnssd package is an Apache HTTPD module which adds Zeroconf support via DNS-SD using Avahi. This allows Apache to advertise itself and the websites available to clients compatible with the protocol. 
Name:       mod-dnssd
Version:    0.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  apache
Requires:  avahi
Source0:    http://0pointer.de/lennart/projects/mod_dnssd/mod_dnssd-0.6.tar.gz
URL:        http://0pointer.de/lennart/projects/mod_dnssd
%description
 The mod_dnssd package is an Apache HTTPD module which adds Zeroconf support via DNS-SD using Avahi. This allows Apache to advertise itself and the websites available to clients compatible with the protocol. 
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
sed -i 's/unixd_setup_child/ap_&/' src/mod_dnssd.c &&
./configure --prefix=/usr --disable-lynx &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/httpd
mkdir -pv ${RPM_BUILD_ROOT}/
make install DESTDIR=${RPM_BUILD_ROOT} 

sed -i 's| usr| ${RPM_BUILD_ROOT}/usr|' ${RPM_BUILD_ROOT}/etc/httpd/httpd.conf


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
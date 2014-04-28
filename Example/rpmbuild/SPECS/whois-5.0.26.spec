%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Whois is a client-side application which queries the whois directory service for information pertaining to a particular domain name. This package by default will install two programs: whois and mkpasswd. The mkpasswd command is also installed by the Expect-5.45 package. 
Name:       whois
Version:    5.0.26
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.debian.org/debian/pool/main/w/whois/whois_5.0.26.tar.xz
Source1:    ftp://ftp.debian.org/debian/pool/main/w/whois/whois_5.0.26.tar.xz
URL:        http://ftp.debian.org/debian/pool/main/w/whois
%description
 Whois is a client-side application which queries the whois directory service for information pertaining to a particular domain name. This package by default will install two programs: whois and mkpasswd. The mkpasswd command is also installed by the Expect-5.45 package. 
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
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make prefix=${RPM_BUILD_ROOT}/usr install-whois DESTDIR=${RPM_BUILD_ROOT} 

make prefix=${RPM_BUILD_ROOT}/usr install-mkpasswd DESTDIR=${RPM_BUILD_ROOT} 

make prefix=${RPM_BUILD_ROOT}/usr install-pos DESTDIR=${RPM_BUILD_ROOT} 


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
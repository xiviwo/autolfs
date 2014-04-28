%define dist BLFS
Summary:     BIND Utilities is not a separate package, it is a collection of the client side programs that are included with BIND-9.9.3-P2. The BIND package includes the client side programs nslookup, dig and host. If you install BIND server, these programs will be installed automatically. This section is for those users who don't need the complete BIND server, but need these client side applications. 
Name:       bind-utilities
Version:    9.9.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.isc.org/isc/bind9/9.9.3-P2/bind-9.9.3-P2.tar.gz
URL:        ftp://ftp.isc.org/isc/bind9/9.9.3-P2
%description
 BIND Utilities is not a separate package, it is a collection of the client side programs that are included with BIND-9.9.3-P2. The BIND package includes the client side programs nslookup, dig and host. If you install BIND server, these programs will be installed automatically. This section is for those users who don't need the complete BIND server, but need these client side applications. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}
./configure --prefix=/usr &&
make -C lib/dns && %{?_smp_mflags} 
make -C lib/isc && %{?_smp_mflags} 
make -C lib/bind9 && %{?_smp_mflags} 
make -C lib/isccfg && %{?_smp_mflags} 
make -C lib/lwres && %{?_smp_mflags} 
make -C bin/dig %{?_smp_mflags} 

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}


make -C bin/dig install DESTDIR=$RPM_BUILD_ROOT 

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
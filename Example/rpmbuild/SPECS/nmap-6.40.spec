%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Nmap is a utility for network exploration and security auditing. It supports ping scanning, port scanning and TCP/IP fingerprinting. 
Name:       nmap
Version:    6.40
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libpcap
Requires:  lua
Requires:  pcre
Requires:  liblinear
Source0:    http://nmap.org/dist/nmap-6.40.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/nmap-6.40.tar.bz2
URL:        http://nmap.org/dist
%description
 Nmap is a utility for network exploration and security auditing. It supports ping scanning, port scanning and TCP/IP fingerprinting. 
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
./configure --prefix=/usr &&
make -j1 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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
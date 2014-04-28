%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GnuTLS package contains libraries and userspace tools which provide a secure layer over a reliable transport layer. Currently the GnuTLS library implements the proposed standards by the IETF's TLS working group. Quoting from the TLS protocol specification: 
Name:       gnutls
Version:    3.2.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  nettle
Requires:  certificate-authority-certificates
Requires:  libtasn1
Source0:    ftp://ftp.gnutls.org/gcrypt/gnutls/v3.2/gnutls-3.2.11.tar.xz
URL:        ftp://ftp.gnutls.org/gcrypt/gnutls/v3.2
%description
 The GnuTLS package contains libraries and userspace tools which provide a secure layer over a reliable transport layer. Currently the GnuTLS library implements the proposed standards by the IETF's TLS working group. Quoting from the TLS protocol specification: 
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
./configure --prefix=/usr --disable-static --with-default-trust-store-file=/etc/ssl/ca-bundle.crt &&
make %{?_smp_mflags} 

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
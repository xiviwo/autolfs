%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The p11-kit package Provides a way to load and enumerate PKCS #11 (a Cryptographic Token Interface Standard) modules. 
Name:       p11-kit
Version:    0.20.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  certificate-authority-certificates
Requires:  libtasn1
Requires:  libffi
Source0:    http://p11-glue.freedesktop.org/releases/p11-kit-0.20.1.tar.gz
URL:        http://p11-glue.freedesktop.org/releases
%description
 The p11-kit package Provides a way to load and enumerate PKCS #11 (a Cryptographic Token Interface Standard) modules. 
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
./configure --prefix=/usr --sysconfdir=/etc 
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
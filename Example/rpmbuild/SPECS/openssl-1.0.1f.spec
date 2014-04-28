%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenSSL package contains management tools and libraries relating to cryptography. These are useful for providing cryptography functions to other packages, such as OpenSSH, email applications and web browsers (for accessing HTTPS sites). 
Name:       openssl
Version:    1.0.1f
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.openssl.org/source/openssl-1.0.1f.tar.gz
Source1:    ftp://ftp.openssl.org/source/openssl-1.0.1f.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/openssl-1.0.1f-fix_parallel_build-1.patch
Source3:    http://www.linuxfromscratch.org/patches/blfs/7.5/openssl-1.0.1f-fix_pod_syntax-1.patch
URL:        http://www.openssl.org/source
%description
 The OpenSSL package contains management tools and libraries relating to cryptography. These are useful for providing cryptography functions to other packages, such as OpenSSH, email applications and web browsers (for accessing HTTPS sites). 
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
patch -Np1 -i %_sourcedir/openssl-1.0.1f-fix_parallel_build-1.patch &&
patch -Np1 -i %_sourcedir/openssl-1.0.1f-fix_pod_syntax-1.patch &&
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic &&
make %{?_smp_mflags} 
sed -i 's# libcrypto.a##;s# libssl.a##' Makefile

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/openssl-1.0.1f
make MANDIR=${RPM_BUILD_ROOT}/usr/share/man MANSUFFIX=ssl install && DESTDIR=${RPM_BUILD_ROOT} 

install -dv -m755 ${RPM_BUILD_ROOT}/usr/share/doc/openssl-1.0.1f  &&

cp -vfr doc/*     ${RPM_BUILD_ROOT}/usr/share/doc/openssl-1.0.1f


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Network Security Services (NSS) package is a set of libraries designed to support cross-platform development of security-enabled client and server applications. Applications built with NSS can support SSL v2 and v3, TLS, PKCS #5, PKCS #7, PKCS #11, PKCS #12, S/MIME, X.509 v3 certificates, and other security standards. This is useful for implementing SSL and S/MIME or other Internet security standards into an application. 
Name:       nss
Version:    3.15.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  nspr
Requires:  sqlite
Source0:    http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_15_4_RTM/src/nss-3.15.4.tar.gz
Source1:    ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_15_4_RTM/src/nss-3.15.4.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/nss-3.15.4-standalone-1.patch
URL:        http://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_15_4_RTM/src
%description
 The Network Security Services (NSS) package is a set of libraries designed to support cross-platform development of security-enabled client and server applications. Applications built with NSS can support SSL v2 and v3, TLS, PKCS #5, PKCS #7, PKCS #11, PKCS #12, S/MIME, X.509 v3 certificates, and other security standards. This is useful for implementing SSL and S/MIME or other Internet security standards into an application. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/pkgconfig
mkdir -pv ${RPM_BUILD_ROOT}/usr/include
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/include/nss
patch -Np1 -i ../nss-3.15.4-standalone-1.patch &&
cd nss &&
make BUILD_OPT=1 NSPR_INCLUDE_DIR=${RPM_BUILD_ROOT}/usr/include/nspr USE_SYSTEM_ZLIB=1 ZLIB_LIBS=-lz $([ $(uname -m) = x86_64 ] && echo USE_64=1) $([ -f ${RPM_BUILD_ROOT}/usr/include/sqlite3.h ] && echo NSS_USE_SYSTEM_SQLITE=1) -j1

cd  %_sourcedir/dist                                                       &&
install -v -m755 Linux*/lib/*.so              ${RPM_BUILD_ROOT}/usr/lib           &&

install -v -m644 Linux*/lib/{*.chk,libcrmf.a} ${RPM_BUILD_ROOT}/usr/lib           &&

install -v -m755 -d                           ${RPM_BUILD_ROOT}/usr/include/nss   &&

cp -v -RL {public,private}/nss/*              ${RPM_BUILD_ROOT}/usr/include/nss   &&

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} ${RPM_BUILD_ROOT}/usr/bin &&

install -v -m644 Linux*/lib/pkgconfig/nss.pc  ${RPM_BUILD_ROOT}/usr/lib/pkgconfig


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 644                                  /usr/include/nss/* &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
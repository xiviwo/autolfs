%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Cyrus SASL package contains a Simple Authentication and Security Layer, a method for adding authentication support to connection-based protocols. To use SASL, a protocol includes a command for identifying and authenticating a user to a server and for optionally negotiating protection of subsequent protocol interactions. If its use is negotiated, a security layer is inserted between the protocol and the connection. 
Name:       cyrus-sasl
Version:    2.1.26
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Requires:  berkeley-db
Source0:    ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/cyrus-sasl-2.1.26-fixes-1.patch
URL:        ftp://ftp.cyrusimap.org/cyrus-sasl
%description
 The Cyrus SASL package contains a Simple Authentication and Security Layer, a method for adding authentication support to connection-based protocols. To use SASL, a protocol includes a command for identifying and authenticating a user to a server and for optionally negotiating protection of subsequent protocol interactions. If its use is negotiated, a security layer is inserted between the protocol and the connection. 
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
patch -Np1 -i %_sourcedir/cyrus-sasl-2.1.26-fixes-1.patch &&
autoreconf -fi &&
pushd saslauthd
autoreconf -fi &&
popd
./configure --prefix=/usr --sysconfdir=/etc --enable-auth-sasldb --with-dbpath=/var/lib/sasl/sasldb2 --with-saslauthd=/var/run/saslauthd &&
make -j1 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/cyrus-sasl-2.1.26
mkdir -pv ${RPM_BUILD_ROOT}/var/lib/sasl
mkdir -pv ${RPM_BUILD_ROOT}/etc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755 ${RPM_BUILD_ROOT}/usr/share/doc/cyrus-sasl-2.1.26 &&

install -v -m644  doc/{*.{html,txt,fig},ONEWS,TODO} saslauthd/LDAP_SASLAUTHD ${RPM_BUILD_ROOT}/usr/share/doc/cyrus-sasl-2.1.26 &&

install -v -dm700 ${RPM_BUILD_ROOT}/var/lib/sasl

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-saslauthd DESTDIR=${RPM_BUILD_ROOT} 


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
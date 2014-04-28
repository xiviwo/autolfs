%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenLDAP package provides an open source implementation of the Lightweight Directory Access Protocol. 
Name:       openldap
Version:    2.4.39
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  berkeley-db
Requires:  cyrus-sasl
Requires:  openssl
Source0:    ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.39.tgz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/openldap-2.4.39-blfs_paths-1.patch
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/openldap-2.4.39-symbol_versions-1.patch
URL:        ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release
%description
 The OpenLDAP package provides an open source implementation of the Lightweight Directory Access Protocol. 
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

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/bin
mkdir -pv ${RPM_BUILD_ROOT}/etc/openldap
mkdir -pv ${RPM_BUILD_ROOT}/etc/openldap/
mkdir -pv ${RPM_BUILD_ROOT}/var/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
patch -Np1 -i ../openldap-2.4.39-blfs_paths-1.patch &&
patch -Np1 -i ../openldap-2.4.39-symbol_versions-1.patch &&
autoconf &&
./configure --prefix=${RPM_BUILD_ROOT}/usr --sysconfdir=${RPM_BUILD_ROOT}/etc --disable-static --enable-dynamic --disable-debug --disable-slapd &&
make depend &&
make &&
make install DESTDIR=${RPM_BUILD_ROOT} 

patch -Np1 -i ../openldap-2.4.39-blfs_paths-1.patch &&
patch -Np1 -i ../openldap-2.4.39-symbol_versions-1.patch &&
autoconf &&
./configure --prefix=${RPM_BUILD_ROOT}/usr --sysconfdir=${RPM_BUILD_ROOT}/etc --localstatedir=${RPM_BUILD_ROOT}/var --libexecdir=${RPM_BUILD_ROOT}/usr/lib --disable-static --disable-debug --enable-dynamic --enable-crypt --enable-spasswd --enable-modules --enable-rlookups --enable-backends=mod --enable-overlays=mod --disable-ndb --disable-sql &&
make depend &&
make
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755  ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.39 &&

cp -vfr doc/drafts ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.39 &&

cp -vfr doc/rfc    ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.39 &&

cp -vfr doc/guide  ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.39

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-slapd DESTDIR=${RPM_BUILD_ROOT} 

ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
groupadd -g 83 ldap &&

useradd -c "OpenLDAP Daemon Owner" -d /var/lib/openldap -u 83 -g ldap -s /bin/false ldap

chmod -v 700 /var/lib/openldap                                         &&

chown -v -R ldap:ldap /var/lib/openldap                                &&

chmod -v 640 /etc/openldap/{slapd.{conf,ldif},DB_CONFIG.example}       &&

chown -v root:ldap /etc/openldap/{slapd.{conf,ldif},DB_CONFIG.example} &&

install -v -dm700 -o ldap -g ldap /etc/openldap/slapd.d                &&

/etc/rc.d/init.d/slapd start
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
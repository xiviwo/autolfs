%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenLDAP package provides an open source implementation of the Lightweight Directory Access Protocol. 
Name:       openldap
Version:    2.4.36
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  berkeley-db
Requires:  cyrus-sasl
Requires:  openssl
Source0:    ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.36.tgz
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.36-blfs_paths-1.patch
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.36-symbol_versions-1.patch
Source3:    http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.36-ntlm-1.patch
URL:        ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release
%description
 The OpenLDAP package provides an open source implementation of the Lightweight Directory Access Protocol. 
%pre
groupadd -g 83 ldap

useradd -c "OpenLDAP Daemon Owner" -d /var/lib/openldap -u 83 -g ldap -s /bin/false ldap
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
patch -Np1 -i %_sourcedir/openldap-2.4.36-ntlm-1.patch
patch -Np1 -i %_sourcedir/openldap-2.4.36-blfs_paths-1.patch 
patch -Np1 -i %_sourcedir/openldap-2.4.36-symbol_versions-1.patch 
autoconf 
./configure --prefix=/usr --sysconfdir=/etc --enable-dynamic --disable-debug --disable-slapd 
make depend %{?_smp_mflags} 

make %{?_smp_mflags} 
patch -Np1 -i %_sourcedir/openldap-2.4.36-blfs_paths-1.patch 
patch -Np1 -i %_sourcedir/openldap-2.4.36-symbol_versions-1.patch 
autoconf 
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/lib --disable-static --disable-debug --enable-dynamic --enable-crypt --enable-spasswd --enable-modules --enable-rlookups --enable-backends=mod --enable-overlays=mod --disable-ndb --disable-sql 
make depend %{?_smp_mflags} 

make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/var/lib
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755  ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.36 

cp -vfr doc/drafts ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.36 

cp -vfr doc/rfc    ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.36 

cp -vfr doc/guide  ${RPM_BUILD_ROOT}/usr/share/doc/openldap-2.4.36

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-slapd DESTDIR=${RPM_BUILD_ROOT} 

ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R ldap:ldap /var/lib/openldap 

/etc/rc.d/init.d/slapd start
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
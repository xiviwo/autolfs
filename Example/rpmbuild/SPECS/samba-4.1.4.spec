%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Samba package provides file and print services to SMB/CIFS clients and Windows networking to Linux clients. Samba can also be configured as a Windows Domain Controller replacement, a file/print server acting as a member of a Windows Active Directory domain and a NetBIOS (rfc1001/1002) nameserver (which among other things provides LAN browsing support). 
Name:       samba
Version:    4.1.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Source0:    http://ftp.samba.org/pub/samba/stable/samba-4.1.4.tar.gz
Source1:    ftp://ftp.samba.org/pub/samba/stable/samba-4.1.4.tar.gz
URL:        http://ftp.samba.org/pub/samba/stable
%description
 The Samba package provides file and print services to SMB/CIFS clients and Windows networking to Linux clients. Samba can also be configured as a Windows Domain Controller replacement, a file/print server acting as a member of a Windows Active Directory domain and a NetBIOS (rfc1001/1002) nameserver (which among other things provides LAN browsing support). 
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-piddir=/run/samba --with-pammodulesdir=/lib/security --enable-fhs --enable-nss-wrapper               &&
make %{?_smp_mflags} 
sed -i "/samba3.blackbox.failure.failure/i \^samba3.raw.eas" selftest/knownfail

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/cups/backend
mkdir -pv ${RPM_BUILD_ROOT}/etc/samba
mkdir -pv ${RPM_BUILD_ROOT}/etc/openldap
mkdir -pv ${RPM_BUILD_ROOT}/etc/openldap/schema
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/dev
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libnss_win{s,bind}.so*   ${RPM_BUILD_ROOT}/lib                       &&

ln -v -sf  %_sourcedir/../lib/libnss_winbind.so.2 ${RPM_BUILD_ROOT}/usr/lib/libnss_winbind.so &&

ln -v -sf  %_sourcedir/../lib/libnss_wins.so.2    ${RPM_BUILD_ROOT}/usr/lib/libnss_wins.so    &&

install -v -m644    examples/smb.conf.default ${RPM_BUILD_ROOT}/etc/samba &&

mkdir -pv -pv ${RPM_BUILD_ROOT}/etc/openldap/schema                        &&

install -v -m644    examples/LDAP/README ${RPM_BUILD_ROOT}/etc/openldap/schema/README.LDAP  &&

                    
install -v -m644    examples/LDAP/samba* ${RPM_BUILD_ROOT}/etc/openldap/schema              &&

                    
install -v -m755    examples/LDAP/{get*,ol*} ${RPM_BUILD_ROOT}/etc/openldap/schema              &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/samba-4.1.4 &&

install -v -m644    lib/ntdb/doc/design.pdf ${RPM_BUILD_ROOT}/usr/share/doc/samba-4.1.4

ln -v -sf ${RPM_BUILD_ROOT}/usr/bin/smbspool ${RPM_BUILD_ROOT}/usr/lib/cups/backend/smb

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-samba DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-winbindd DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
groupadd -g 99 nogroup &&

useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup -s /bin/false -u 99 nobody
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
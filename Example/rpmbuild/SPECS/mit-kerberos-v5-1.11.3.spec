%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     MIT Kerberos V5 is a free implementation of Kerberos 5. Kerberos is a network authentication protocol. It centralizes the authentication database and uses kerberized applications to work with servers or services that support Kerberos allowing single logins and encrypted communication over internal networks or the Internet. 
Name:       mit-kerberos-v5
Version:    1.11.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://web.mit.edu/kerberos/www/dist/krb5/1.11/krb5-1.11.3-signed.tar
URL:        http://web.mit.edu/kerberos/www/dist/krb5/1.11
%description
 MIT Kerberos V5 is a free implementation of Kerberos 5. Kerberos is a network authentication protocol. It centralizes the authentication database and uses kerberized applications to work with servers or services that support Kerberos allowing single logins and encrypted communication over internal networks or the Internet. 
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
cd src 
sed -e "s@python2.5/Python.h@& python2.7/Python.h@g" -e "s@-lpython2.5]@&,\n  AC_CHECK_LIB(python2.7,main,[PYTHON_LIB=-lpython2.7])@g" -i configure.in 
sed -e "s@interp->result@Tcl_GetStringResult(interp)@g" -i kadmin/testing/util/tcl_kadm5.c 
autoconf 
./configure CPPFLAGS="-I/usr/include/et -I/usr/include/ss" --prefix=/usr --sysconfdir=/etc --localstatedir=/var/lib --with-system-et --with-system-ss --enable-dns-for-realm 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd src 

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/krb5-1.11.3
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/lib
make install  DESTDIR=${RPM_BUILD_ROOT} 

for LIBRARY in gssapi_krb5 gssrpc k5crypto kadm5clnt_mit kadm5srv_mit kdb5 kdb_ldap krb5 krb5support verto ; do
    [ -e  ${RPM_BUILD_ROOT}/usr/lib/lib$LIBRARY.so.*.* ] && chmod -v 755 ${RPM_BUILD_ROOT}/usr/lib/lib$LIBRARY.so.*.*

done 
mv -v ${RPM_BUILD_ROOT}/usr/lib/libkrb5.so.3*        ${RPM_BUILD_ROOT}/lib 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libk5crypto.so.3*    ${RPM_BUILD_ROOT}/lib 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libkrb5support.so.0* ${RPM_BUILD_ROOT}/lib 

ln -v -sf  %_sourcedir/../lib/libkrb5.so.3.3        ${RPM_BUILD_ROOT}/usr/lib/libkrb5.so        

ln -v -sf  %_sourcedir/../lib/libk5crypto.so.3.1    ${RPM_BUILD_ROOT}/usr/lib/libk5crypto.so    

ln -v -sf  %_sourcedir/../lib/libkrb5support.so.0.1 ${RPM_BUILD_ROOT}/usr/lib/libkrb5support.so 

mv -v ${RPM_BUILD_ROOT}/usr/bin/ksu ${RPM_BUILD_ROOT}/bin 

install -v -dm755 ${RPM_BUILD_ROOT}/usr/share/doc/krb5-1.11.3 

cp -vfr ../doc/*  ${RPM_BUILD_ROOT}/usr/share/doc/krb5-1.11.3 

unset LIBRARY
cat > /etc/krb5.conf << "EOF"
# Begin /etc/krb5.conf
[libdefaults]
    default_realm = <LFS.ORG>
    encrypt = true
[realms]
    <LFS.ORG> = {
        kdc = <belgarath.lfs.org>
        admin_server = <belgarath.lfs.org>
        dict_file = /usr/share/dict/words
    }
[domain_realm]
    .<lfs.org> = <LFS.ORG>
[logging]
    kdc = SYSLOG[:INFO[:AUTH]]
    admin_server = SYSLOG[INFO[:AUTH]]
    default = SYSLOG[[:SYS]]
# End /etc/krb5.conf
EOF
kdb5_util create -r <LFS.ORG> -s
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-krb5 DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /bin/ksu   

kadmin.local

kadmin: add_policy dict-only

kadmin: addprinc -policy dict-only <loginname>

kadmin: addprinc -randkey host/<belgarath.lfs.org>

kadmin: ktadd host/<belgarath.lfs.org>

/usr/sbin/krb5kdc

kinit <loginname>

klist

ktutil

ktutil: rkt /etc/krb5.keytab

ktutil: l
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
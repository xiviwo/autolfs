%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Dovecot is an Internet Message Access Protocol (IMAP) and Post Office Protocol (POP) server, written primarily with security in mind. Dovecot aims to be lightweight, fast and easy to set up as well as highly configurable and easily extensible with plugins. 
Name:       dovecot
Version:    2.2.12
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.dovecot.org/releases/2.2/dovecot-2.2.12.tar.gz
URL:        http://www.dovecot.org/releases/2.2
%description
 Dovecot is an Internet Message Access Protocol (IMAP) and Post Office Protocol (POP) server, written primarily with security in mind. Dovecot aims to be lightweight, fast and easy to set up as well as highly configurable and easily extensible with plugins. 
%pre
groupadd -g 42 dovecot  || :

useradd -c "Dovecot unprivileged user" -d /dev/null -u 42 -g dovecot -s /bin/false dovecot  || :

groupadd -g 43 dovenull  || :

useradd -c "Dovecot login user" -d /dev/null -u 43 -g dovenull -s /bin/false dovenull || :
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --docdir=/usr/share/doc/dovecot-2.2.12 --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/dovecot
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/dovecot-2.2.12/example-config
mkdir -pv ${RPM_BUILD_ROOT}/
mkdir -pv ${RPM_BUILD_ROOT}/var/mail
make install DESTDIR=${RPM_BUILD_ROOT} 

cp -rv ${RPM_BUILD_ROOT}/usr/share/doc/dovecot-2.2.12/example-config/* ${RPM_BUILD_ROOT}/etc/dovecot

sed -i '/^\!include ${RPM_BUILD_ROOT}/ s/^/#/' ${RPM_BUILD_ROOT}/etc/dovecot/dovecot.conf &&

cat > /etc/dovecot/local.conf << "EOF"
protocols = imap
ssl = no
# The next line is only needed if you have no IPv6 network interfaces
listen = *
mail_location = mbox:~/Mail:INBOX=/var/mail/%u
userdb {
  driver = passwd
}
passdb {
  driver = shadow
}
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-dovecot DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 1777 /var/mail &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
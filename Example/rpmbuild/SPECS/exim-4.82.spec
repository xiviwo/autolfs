%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Exim package contains a Mail Transport Agent written by the University of Cambridge, released under the GNU Public License. 
Name:       exim
Version:    4.82
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  pcre
Source0:    http://ftp.exim.org/pub/exim/exim4/exim-4.82.tar.bz2
Source1:    ftp://ftp.exim.org/pub/exim/exim4/exim-4.82.tar.bz2
URL:        http://ftp.exim.org/pub/exim/exim4
%description
 The Exim package contains a Mail Transport Agent written by the University of Cambridge, released under the GNU Public License. 
%pre
groupadd -g 31 exim  || :

useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim || :
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
sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,' -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' -e 's,^EXIM_USER.*$,EXIM_USER=exim,' -e 's,^EXIM_MONITOR,#EXIM_MONITOR,' src/EDITME > Local/Makefile &&
echo -e "USE_GDBM = yes\nDBMLIB = -lgdbm" >> Local/Makefile &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man8
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 doc/exim.8 ${RPM_BUILD_ROOT}/usr/share/man/man8 &&

install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/doc/exim-4.82 &&

install -v -m644 doc/* ${RPM_BUILD_ROOT}/usr/share/doc/exim-4.82 &&

ln -sfv exim ${RPM_BUILD_ROOT}/usr/sbin/sendmail

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-exim DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/aliases << "EOF"

postmaster: root

MAILER-DAEMON: root

EOF

exim -v -bi &&

/usr/sbin/exim -bd -q15m
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
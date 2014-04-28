%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Fcron package contains a periodical command scheduler which aims at replacing Vixie Cron. 
Name:       fcron
Version:    3.1.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://fcron.free.fr/archives/fcron-3.1.2.src.tar.gz
Source1:    ftp://ftp.seul.org/pub/fcron/fcron-3.1.2.src.tar.gz
URL:        http://fcron.free.fr/archives
%description
 The Fcron package contains a periodical command scheduler which aims at replacing Vixie Cron. 
%pre
groupadd -g 22 fcron  || :

useradd -d /dev/null -c "Fcron User" -g fcron -s /bin/false -u 22 fcron || :
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
cat >> /etc/syslog.conf << "EOF"
# Begin fcron addition to /etc/syslog.conf
cron.* -/var/log/cron.log
# End fcron addition
EOF
/etc/rc.d/init.d/sysklogd reload

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
./configure --prefix=${RPM_BUILD_ROOT}/usr --sysconfdir=${RPM_BUILD_ROOT}/etc --localstatedir=${RPM_BUILD_ROOT}/var --without-sendmail --with-boot-install=no &&
make
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-fcron DESTDIR=${RPM_BUILD_ROOT} 


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
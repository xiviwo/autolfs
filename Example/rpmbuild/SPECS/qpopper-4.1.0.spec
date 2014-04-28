%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Qpopper package contains a POP3 mail server. 
Name:       qpopper
Version:    4.1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  chapter
Source0:    ftp://ftp.qualcomm.com/eudora/servers/unix/popper/qpopper4.1.0.tar.gz
URL:        ftp://ftp.qualcomm.com/eudora/servers/unix/popper
%description
 The Qpopper package contains a POP3 mail server. 
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
./configure --prefix=/usr --enable-standalone 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/var/log
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/qpopper-4.1.0
mkdir -pv ${RPM_BUILD_ROOT}/etc/mail
mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -D -m644 GUIDE.pdf ${RPM_BUILD_ROOT}/usr/share/doc/qpopper-4.1.0/GUIDE.pdf

killall -HUP syslogd
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-qpopper DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
cat > /etc/mail/qpopper.conf << "EOF"
# Qpopper configuration file
set debug = false
set spool-dir = /var/spool/mail/
set temp-dir  = /var/spool/mail/
set downcase-user = true
set trim-domain = true
set statistics = true
# End /etc/shells
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
killall inetd || inetd

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo "local0.notice;local0.debug /var/log/POP.log" >> /etc/syslog.conf 

echo "pop3 stream tcp nowait root /usr/sbin/popper popper" >> /etc/inetd.conf 
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
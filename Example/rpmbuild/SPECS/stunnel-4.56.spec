%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The stunnel package contains a program that allows you to encrypt arbitrary TCP connections inside SSL (Secure Sockets Layer) so you can easily communicate with clients over secure channels. stunnel can be used to add SSL functionality to commonly used Inetd daemons like POP-2, POP-3, and IMAP servers, to standalone daemons like NNTP, SMTP and HTTP, and in tunneling PPP over network sockets without changes to the server package source code. 
Name:       stunnel
Version:    4.56
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://mirrors.zerg.biz/stunnel/stunnel-4.56.tar.gz
Source1:    ftp://ftp.stunnel.org/stunnel/stunnel-4.56.tar.gz
URL:        http://mirrors.zerg.biz/stunnel
%description
 The stunnel package contains a program that allows you to encrypt arbitrary TCP connections inside SSL (Secure Sockets Layer) so you can easily communicate with clients over secure channels. stunnel can be used to add SSL functionality to commonly used Inetd daemons like POP-2, POP-3, and IMAP servers, to standalone daemons like NNTP, SMTP and HTTP, and in tunneling PPP over network sockets without changes to the server package source code. 
%pre
groupadd -g 51 stunnel  || :

useradd -c "stunnel Daemon" -d /var/lib/stunnel -g stunnel -s /bin/false -u 51 stunnel || :
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-fips &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/var/lib/stunnel/run
mkdir -pv ${RPM_BUILD_ROOT}/var/lib/stunnel
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/stunnel
make docdir=${RPM_BUILD_ROOT}/usr/share/doc/stunnel-4.56 install DESTDIR=${RPM_BUILD_ROOT} 

cat >/etc/stunnel/stunnel.conf << "EOF" &&
; File: /etc/stunnel/stunnel.conf
pid    = /run/stunnel.pid
chroot = /var/lib/stunnel
client = no
setuid = stunnel
setgid = stunnel
cert   = /etc/stunnel/stunnel.pem
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-stunnel DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
install -v -m750 -o stunnel -g stunnel -d /var/lib/stunnel/run &&

chown stunnel:stunnel /var/lib/stunnel

chmod -v 644 /etc/stunnel/stunnel.conf
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
%define dist BLFS
Summary:     The BIND package provides a DNS server and client utilities. If you are only interested in the utilities, refer to the BIND Utilities-9.9.3-P2. 
Name:       bind
Version:    9.9.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.isc.org/isc/bind9/9.9.3-P2/bind-9.9.3-P2.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/bind-9.9.3-P2-use_iproute2-1.patch
URL:        ftp://ftp.isc.org/isc/bind9/9.9.3-P2
%description
 The BIND package provides a DNS server and client utilities. If you are only interested in the utilities, refer to the BIND Utilities-9.9.3-P2. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}
patch -Np1 -i %_sourcedir/bind-9.9.3-P2-use_iproute2-1.patch
./configure --prefix=/usr           \
            --sysconfdir=/etc       \
            --localstatedir=/var    \
            --mandir=/usr/share/man \
            --enable-threads        \
            --with-libtool          \
            --disable-static        &&
make %{?_smp_mflags} 
bin/tests/system/ifconfig.sh up
make check 2>&1 | tee check.log %{?_smp_mflags} 
bin/tests/system/ifconfig.sh down
grep "R:PASS" check.log | wc -l

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/srv/named
mkdir -pv $RPM_BUILD_ROOT/etc
mkdir -pv $RPM_BUILD_ROOT/srv/named/etc/namedb
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc/bind-9.9.3-P2
mkdir -pv $RPM_BUILD_ROOT/bin
mkdir -pv $RPM_BUILD_ROOT/dev
mkdir -pv $RPM_BUILD_ROOT/srv
mkdir -pv $RPM_BUILD_ROOT/srv/named/etc/namedb/pz
mkdir -pv $RPM_BUILD_ROOT/srv/named/etc
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/usr/lib/engines
mkdir -pv $RPM_BUILD_ROOT/srv/named/dev
make install DESTDIR=$RPM_BUILD_ROOT &&
chmod -v 0755 ${RPM_BUILD_ROOT}/usr/lib/lib{bind9,isc{,cc,cfg},lwres,dns}.so.*.?.? &&
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/bind-9.9.3-P2/{arm,misc} &&
install -v -m644    doc/arm/*.html \
                    ${RPM_BUILD_ROOT}/usr/share/doc/bind-9.9.3-P2/arm &&
install -v -m644 \
    doc/misc/{dnssec,ipv6,migrat*,options,rfc-compliance,roadmap,sdb} \
    ${RPM_BUILD_ROOT}/usr/share/doc/bind-9.9.3-P2/misc
groupadd -g 20 named &&
useradd -c "BIND Owner" -g named -s ${RPM_BUILD_ROOT}/bin/false -u 20 named &&
install -d -m770 -o named -g named ${RPM_BUILD_ROOT}/srv/named
cd ${RPM_BUILD_ROOT}/srv/named &&
mkdir -pv -p dev etc/namedb/{slave,pz} usr/lib/engines var/run/named &&
mknod ${RPM_BUILD_ROOT}/srv/named/dev/null c 1 3 &&
mknod ${RPM_BUILD_ROOT}/srv/named/dev/random c 1 8 &&
chmod 666 ${RPM_BUILD_ROOT}/srv/named/dev/{null,random} &&
cp ${RPM_BUILD_ROOT}/etc/localtime etc &&
touch ${RPM_BUILD_ROOT}/srv/named/managed-keys.bind &&
cp ${RPM_BUILD_ROOT}/usr/lib/engines/libgost.so usr/lib/engines &&
[ $(uname -m) = x86_64 ] && ln -sv lib usr/lib64
rndc-confgen -r ${RPM_BUILD_ROOT}/dev/urandom -b 512 > ${RPM_BUILD_ROOT}/etc/rndc.conf &&
sed '/conf/d;/^#/!d;s:^# ::' ${RPM_BUILD_ROOT}/etc/rndc.conf > ${RPM_BUILD_ROOT}/srv/named/etc/named.conf
cat >> ${RPM_BUILD_ROOT}/srv/named/etc/named.conf << "EOF"
options {
    directory "/etc/namedb";
    pid-file "/var/run/named.pid";
    statistics-file "/var/run/named.stats";
};
zone "." {
    type hint;
    file "root.hints";
};
zone "0.0.127.in-addr.arpa" {
    type master;
    file "pz/127.0.0";
};
// Bind 9 now logs by default through syslog (except debug).
// These are the default logging rules.
logging {
    category default { default_syslog; default_debug; };
    category unmatched { null; };
  channel default_syslog {
      syslog daemon;                      // send to syslog's daemon
                                          // facility
      severity info;                      // only send priority info
                                          // and higher
  };
  channel default_debug {
      file "named.run";                   // write to named.run in
                                          // the working directory
                                          // Note: stderr is used instead
                                          // of "named.run"
                                          // if the server is started
                                          // with the '-f' option.
      severity dynamic;                   // log at the server's
                                          // current debug level
  };
  channel default_stderr {
      stderr;                             // writes to stderr
      severity info;                      // only send priority info
                                          // and higher
  };
  channel null {
      null;                               // toss anything sent to
                                          // this channel
  };
};
EOF
cat > ${RPM_BUILD_ROOT}/srv/named/etc/namedb/pz/127.0.0 << "EOF"
$TTL 3D
@      IN      SOA     ns.local.domain. hostmaster.local.domain. (
                        1       ; Serial
                        8H      ; Refresh
                        2H      ; Retry
                        4W      ; Expire
                        1D)     ; Minimum TTL
                NS      ns.local.domain.
1               PTR     localhost.
EOF
cat > ${RPM_BUILD_ROOT}/srv/named/etc/namedb/root.hints << "EOF"
.                       6D  IN      NS      A.ROOT-SERVERS.NET.
.                       6D  IN      NS      B.ROOT-SERVERS.NET.
.                       6D  IN      NS      C.ROOT-SERVERS.NET.
.                       6D  IN      NS      D.ROOT-SERVERS.NET.
.                       6D  IN      NS      E.ROOT-SERVERS.NET.
.                       6D  IN      NS      F.ROOT-SERVERS.NET.
.                       6D  IN      NS      G.ROOT-SERVERS.NET.
.                       6D  IN      NS      H.ROOT-SERVERS.NET.
.                       6D  IN      NS      I.ROOT-SERVERS.NET.
.                       6D  IN      NS      J.ROOT-SERVERS.NET.
.                       6D  IN      NS      K.ROOT-SERVERS.NET.
.                       6D  IN      NS      L.ROOT-SERVERS.NET.
.                       6D  IN      NS      M.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.     6D  IN      A       198.41.0.4
B.ROOT-SERVERS.NET.     6D  IN      A       192.228.79.201
C.ROOT-SERVERS.NET.     6D  IN      A       192.33.4.12
D.ROOT-SERVERS.NET.     6D  IN      A       199.7.91.13
E.ROOT-SERVERS.NET.     6D  IN      A       192.203.230.10
F.ROOT-SERVERS.NET.     6D  IN      A       192.5.5.241
G.ROOT-SERVERS.NET.     6D  IN      A       192.112.36.4
H.ROOT-SERVERS.NET.     6D  IN      A       128.63.2.53
I.ROOT-SERVERS.NET.     6D  IN      A       192.36.148.17
J.ROOT-SERVERS.NET.     6D  IN      A       192.58.128.30
K.ROOT-SERVERS.NET.     6D  IN      A       193.0.14.129
L.ROOT-SERVERS.NET.     6D  IN      A       199.7.83.42
M.ROOT-SERVERS.NET.     6D  IN      A       202.12.27.33
EOF
cp ${RPM_BUILD_ROOT}/etc/resolv.conf ${RPM_BUILD_ROOT}/etc/resolv.conf.bak &&
cat > ${RPM_BUILD_ROOT}/etc/resolv.conf << "EOF"
search <yourdomain.com>
nameserver 127.0.0.1
EOF
chown -R named:named ${RPM_BUILD_ROOT}/srv/named
make install-bind DESTDIR=$RPM_BUILD_ROOT 
/etc/rc.d/init.d/bind start
dig -x 127.0.0.1
dig www.linuxfromscratch.org &&
dig www.linuxfromscratch.org

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bind
version=9.9.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.isc.org/isc/bind9/9.9.5/bind-9.9.5.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/bind-9.9.5-use_iproute2-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" bind-9.9.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../bind-9.9.5-use_iproute2-1.patch

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man --enable-threads --with-libtool --disable-static --with-randomdev=/dev/urandom 
make

bin/tests/system/ifconfig.sh up

make check 2>&1 | tee check.log

bin/tests/system/ifconfig.sh down

grep "R:PASS" check.log | wc -l

make install 
chmod -v 0755 /usr/lib/lib{bind9,dns,isc{,cc,cfg},lwres}.so 

install -v -m755 -d /usr/share/doc/bind-9.9.5/{arm,misc} 
install -v -m644    doc/arm/*.html /usr/share/doc/bind-9.9.5/arm 
install -v -m644 doc/misc/{dnssec,ipv6,migrat*,options,rfc-compliance,roadmap,sdb} /usr/share/doc/bind-9.9.5/misc

groupadd -g 20 named 
useradd -c "BIND Owner" -g named -s /bin/false -u 20 named 
install -d -m770 -o named -g named /srv/named

cd /srv/named 
mkdir -pv -p dev etc/namedb/{slave,pz} usr/lib/engines var/run/named 
mknod /srv/named/dev/null c 1 3 
mknod /srv/named/dev/random c 1 8 
chmod 666 /srv/named/dev/{null,random} 
cp /etc/localtime etc 
touch /srv/named/managed-keys.bind 
cp /usr/lib/engines/libgost.so usr/lib/engines 
[ $(uname -m) = x86_64 ] && ln -svf lib usr/lib64

rndc-confgen -r /dev/urandom -b 512 > /etc/rndc.conf 
sed '/conf/d;/^#/!d;s:^# ::' /etc/rndc.conf > /srv/named/etc/named.conf

cat >> /srv/named/etc/named.conf << "EOF"
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

cat > /srv/named/etc/namedb/pz/127.0.0 << "EOF"
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

cat > /srv/named/etc/namedb/root.hints << "EOF"
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

cp /etc/resolv.conf /etc/resolv.conf.bak 
cat > /etc/resolv.conf << "EOF"
search <yourdomain.com>
nameserver 127.0.0.1
EOF

chown -R named:named /srv/named

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-bind

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

/etc/rc.d/init.d/bind start

dig -x 127.0.0.1

dig www.linuxfromscratch.org 
dig www.linuxfromscratch.org


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

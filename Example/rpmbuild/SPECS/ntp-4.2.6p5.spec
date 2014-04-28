%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ntp package contains a client and server to keep the time synchronized between various computers over a network. This package is the official reference implementation of the NTP protocol. 
Name:       ntp
Version:    4.2.6p5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libcap
Source0:    http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.6p5.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/ntp-4.2.6p5.tar.gz
URL:        http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2
%description
 The ntp package contains a client and server to keep the time synchronized between various computers over a network. This package is the official reference implementation of the NTP protocol. 
%pre
groupadd -g 87 ntp  || :

useradd -c "Network Time Protocol" -d /var/lib/ntp -u 87 -g ntp -s /bin/false ntp || :
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
./configure --prefix=/usr --sysconfdir=/etc --enable-linuxcaps --with-binsubdir=sbin --with-lineeditlibs=readline &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/rc.d/rc0.d
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/var/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/ntp-4.2.6p5
mkdir -pv ${RPM_BUILD_ROOT}/etc/rc.d/rc6.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/ntp-4.2.6p5 &&

cp -v -R html/* ${RPM_BUILD_ROOT}/usr/share/doc/ntp-4.2.6p5/

cat > /etc/ntp.conf << "EOF"
# Asia
server 0.asia.pool.ntp.org
# Australia
server 0.oceania.pool.ntp.org
# Europe
server 0.europe.pool.ntp.org
# North America
server 0.north-america.pool.ntp.org
# South America
server 2.south-america.pool.ntp.org
driftfile /var/lib/ntp/ntp.drift
pidfile   /var/run/ntpd.pid
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-ntpd DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
ln -v -sf  %_sourcedir/init.d/setclock ${RPM_BUILD_ROOT}/etc/rc.d/rc0.d/K46setclock &&

ln -v -sf  %_sourcedir/init.d/setclock ${RPM_BUILD_ROOT}/etc/rc.d/rc6.d/K46setclock


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
install -v -o ntp -g ntp -d /var/lib/ntp &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     xinetd is the eXtended InterNET services daemon, a secure replacement for inetd. 
Name:       xinetd
Version:    2.3.15
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xinetd-2.3.15.tar.gz
URL:        ftp://mirror.ovh.net/gentoo-distfiles/distfiles
%description
 xinetd is the eXtended InterNET services daemon, a secure replacement for inetd. 
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
sed -i -e "s/exec_server/child_process/" xinetd/builtins.c        &&
sed -i -e "/register unsigned count/s/register//" xinetd/itox.c  &&
./configure --prefix=/usr --mandir=/usr/share/man --with-loadavg &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/xinetd.d
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/xinetd.conf << "EOF"
# Begin /etc/xinetd
# Configuration file for xinetd
defaults
{
      instances       = 60
      log_type        = SYSLOG daemon
      log_on_success  = HOST PID USERID
      log_on_failure  = HOST USERID
      cps             = 25 30
}
# All service files are stored in the /etc/xinetd.d directory
includedir /etc/xinetd.d
# End /etc/xinetd
EOF
install -v -d -m755 ${RPM_BUILD_ROOT}/etc/xinetd.d &&

cat > /etc/xinetd.d/systat << "EOF" &&
# Begin /etc/xinetd.d/systat
service systat
{
   disable           = yes
   socket_type       = stream
   wait              = no
   user              = nobody
   server            = /bin/ps
   server_args       = -auwwx
   only_from         = 128.138.209.0
   log_on_success    = HOST
}
# End /etc/xinetd.d/systat
EOF
cat > /etc/xinetd.d/echo << "EOF" &&
# Begin /etc/xinetd.d/echo
service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-stream
   socket_type = stream
   protocol    = tcp
   user        = root
   wait        = no
}
service echo
{
   disable     = yes
   type        = INTERNAL
   id          = echo-dgram
   socket_type = dgram
   protocol    = udp
   user        = root
   wait        = yes
}
# End /etc/xinetd.d/echo
EOF
cat > /etc/xinetd.d/chargen << "EOF" &&
# Begin /etc/xinetd.d/chargen
service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}
service chargen
{
   disable        = yes
   type           = INTERNAL
   id             = chargen-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}
# End /etc/xinetd.d/chargen
EOF
cat > /etc/xinetd.d/daytime << "EOF" &&
# Begin /etc/xinetd.d/daytime
service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}
service daytime
{
   disable        = yes
   type           = INTERNAL
   id             = daytime-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}
# End /etc/xinetd.d/daytime
EOF
cat > /etc/xinetd.d/time << "EOF"
# Begin /etc/xinetd.d/time
service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-stream
   socket_type    = stream
   protocol       = tcp
   user           = root
   wait           = no
}
service time
{
   disable        = yes
   type           = INTERNAL
   id             = time-dgram
   socket_type    = dgram
   protocol       = udp
   user           = root
   wait           = yes
}
# End /etc/xinetd.d/time
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-xinetd DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/etc/rc.d/init.d/xinetd start
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
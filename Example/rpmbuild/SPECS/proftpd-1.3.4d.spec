%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ProFTPD package contains a secure and highly configurable FTP daemon. This is useful for serving large file archives over a network. 
Name:       proftpd
Version:    1.3.4d
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.4d.tar.gz
URL:        ftp://ftp.proftpd.org/distrib/source
%description
 The ProFTPD package contains a secure and highly configurable FTP daemon. This is useful for serving large file archives over a network. 
%pre
groupadd -g 46 proftpd                              || :

useradd -c proftpd -d /srv/ftp -g proftpd -s /usr/bin/proftpdshell -u 46 proftpd      || :

install -v -d -m775 -o proftpd -g proftpd /srv/ftp &&
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
ln -v -s /bin/false /usr/bin/proftpdshell          &&
echo /usr/bin/proftpdshell >> /etc/shells
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var/run &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/proftpd.conf << "EOF"
# This is a basic ProFTPD configuration file
# It establishes a single server and a single anonymous login.
ServerName                      "ProFTPD Default Installation"
ServerType                      standalone
DefaultServer                   on
# Port 21 is the standard FTP port.
Port                            21
# Umask 022 is a good standard umask to prevent new dirs and files
# from being group and world writable.
Umask                           022
# To prevent DoS attacks, set the maximum number of child processes
# to 30.  If you need to allow more than 30 concurrent connections
# at once, simply increase this value.  Note that this ONLY works
# in standalone mode, in inetd mode you should use an inetd server
# that allows you to limit maximum number of processes per service
MaxInstances                    30
# Set the user and group that the server normally runs at.
User                            proftpd
Group                           proftpd
# Normally, files should be overwritable.
<Directory /*>
  AllowOverwrite                on
</Directory>
# A basic anonymous configuration, no upload directories.
<Anonymous ~proftpd>
  User                          proftpd
  Group                         proftpd
  # Clients should be able to login with "anonymous" as well as "proftpd"
  UserAlias                     anonymous proftpd
  # Limit the maximum number of anonymous logins
  MaxClients                    10
  # 'welcome.msg' should be displayed at login, and '.message' displayed
  # in each newly chdired directory.
  DisplayLogin                  welcome.msg
  DisplayChdir                  .message
  # Limit WRITE everywhere in the anonymous chroot
  <Limit WRITE>
    DenyAll
  </Limit>
</Anonymous>
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-proftpd DESTDIR=${RPM_BUILD_ROOT} 


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The vsftpd package contains a very secure and very small FTP daemon. This is useful for serving files over a network. 
Name:       vsftpd
Version:    3.0.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    https://security.appspot.com/downloads/vsftpd-3.0.2.tar.gz
URL:        https://security.appspot.com/downloads
%description
 The vsftpd package contains a very secure and very small FTP daemon. This is useful for serving files over a network. 
%pre
install -v -d -m 0755 /usr/share/vsftpd/empty &&

install -v -d -m 0755 /home/ftp               &&

groupadd -g 47 vsftpd                          || :

groupadd -g 45 ftp                             || :

useradd -c "vsftpd User"  -d /dev/null -g vsftpd -s /bin/false -u 47 vsftpd  || :

useradd -c anonymous_user -d /home/ftp -g ftp    -s /bin/false -u 45 ftp || :

install -v -m 755 vsftpd        /usr/sbin/vsftpd    &&

install -v -m 644 vsftpd.8      /usr/share/man/man8 &&

install -v -m 644 vsftpd.conf.5 /usr/share/man/man5 &&

install -v -m 644 vsftpd.conf   /etc
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
sed -i -e 's|#define VSF_SYSDEP_HAVE_LIBCAP|//&|' sysdeputil.c
make %{?_smp_mflags} 
cat >> /etc/vsftpd.conf << "EOF"
background=YES
listen=YES
nopriv_user=vsftpd
secure_chroot_dir=/usr/share/vsftpd/empty
EOF
mkdir -pv /etc
mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ${SOURCES}/blfs-boot-scripts


make install-vsftpd DESTDIR=${RPM_BUILD_ROOT} 


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
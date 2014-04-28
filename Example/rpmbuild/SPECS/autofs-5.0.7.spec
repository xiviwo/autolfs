%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Autofs package contains userspace tools that work with the kernel to mount and un-mount removable file systems. The primary use is to mount external network file systems like NFS (see nfs-utils-1.2.8) or Samba (see Samba-4.0.9) on demand. 
Name:       autofs
Version:    5.0.7
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  openldap
Requires:  cyrus-sasl
Requires:  mit-kerberos-v5
Source0:    http://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.7.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.7.tar.xz
URL:        http://ftp.kernel.org/pub/linux/daemons/autofs/v5
%description
 The Autofs package contains userspace tools that work with the kernel to mount and un-mount removable file systems. The primary use is to mount external network file systems like NFS (see nfs-utils-1.2.8) or Samba (see Samba-4.0.9) on demand. 
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
./configure --prefix=/ --mandir=/usr/share/man 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mv ${RPM_BUILD_ROOT}/etc/auto.master ${RPM_BUILD_ROOT}/etc/auto.master.bak 

cat > /etc/auto.master << "EOF"
# Begin /etc/auto.master
/media/auto  /etc/auto.misc  --ghost
#/home        /etc/auto.home
# End /etc/auto.master
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-autofs DESTDIR=${RPM_BUILD_ROOT} 


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
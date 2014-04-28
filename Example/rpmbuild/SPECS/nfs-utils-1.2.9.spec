%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The NFS Utilities package contains the userspace server and client tools necessary to use the kernel's NFS abilities. NFS is a protocol that allows sharing file systems over the network. 
Name:       nfs-utils
Version:    1.2.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libtirpc
Requires:  rpcbind
Source0:    http://downloads.sourceforge.net/nfs/nfs-utils-1.2.9.tar.bz2
URL:        http://downloads.sourceforge.net/nfs
%description
 The NFS Utilities package contains the userspace server and client tools necessary to use the kernel's NFS abilities. NFS is a protocol that allows sharing file systems over the network. 
%pre
groupadd -g 99 nogroup  || :

useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup -s /bin/false -u 99 nobody || :
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
./configure --prefix=/usr --sysconfdir=/etc --without-tcp-wrappers --disable-nfsv4 --disable-gss &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
mkdir -pv ${RPM_BUILD_ROOT}/usr
mkdir -pv ${RPM_BUILD_ROOT}/home
make install DESTDIR=${RPM_BUILD_ROOT} 

/home <192.168.0.0/24>(rw,subtree_check,anonuid=99,anongid=99)
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-nfs-server DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
cat > /etc/sysconfig/nfs-server << "EOF"
PORT="2049"
PROCESSES="8"
QUOTAS="no"
KILLDELAY="10"
EOF
<server-name>:/home  ${RPM_BUILD_ROOT}/home nfs   rw,_netdev,rsize=8192,wsize=8192 0 0

<server-name>:/usr   ${RPM_BUILD_ROOT}/usr  nfs   ro,_netdev,rsize=8192            0 0

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-nfs-client DESTDIR=${RPM_BUILD_ROOT} 


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The NFS Utilities package contains the userspace server and client tools necessary to use the kernel's NFS abilities. NFS is a protocol that allows sharing file systems over the network. 
Name:       nfs-utils
Version:    1.2.8
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libtirpc
Requires:  pkg-config
Requires:  rpcbind
Source0:    http://downloads.sourceforge.net/nfs/nfs-utils-1.2.8.tar.bz2
URL:        http://downloads.sourceforge.net/nfs
%description
 The NFS Utilities package contains the userspace server and client tools necessary to use the kernel's NFS abilities. NFS is a protocol that allows sharing file systems over the network. 
%pre
groupadd -g 99 nogroup

useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup -s /bin/false -u 99 nobody
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
./configure --prefix=/usr --sysconfdir=/etc --without-tcp-wrappers --disable-nfsv4 --disable-nfsv41 --disable-gss 
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

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
make install-nfs-server DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
cat > /etc/sysconfig/nfs-server << "EOF"
PORT="2049"
PROCESSES="8"
QUOTAS="no"
KILLDELAY="10"
EOF
<server-name>:/home  ${RPM_BUILD_ROOT}/home nfs   rw,_netdev,rsize=8192,wsize=8192 0 0

<server-name>:/usr   ${RPM_BUILD_ROOT}/usr  nfs   ro,_netdev,rsize=8192            0 0

cat > /etc/netconfig << "EOF"
udp6 tpi_clts v inet6 udp - -
tcp6 tpi_cots_ord v inet6 tcp - -
udp tpi_clts v inet udp - -
tcp tpi_cots_ord v inet tcp - -
rawip tpi_raw - inet - - -
local tpi_cots_ord - loopback - - -
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts
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
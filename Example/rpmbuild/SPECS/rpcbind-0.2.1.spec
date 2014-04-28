%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The rpcbind program is a replacement for portmap. It is required for import or export of Network File System (NFS) shared directories. 
Name:       rpcbind
Version:    0.2.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libtirpc
Source0:    http://downloads.sourceforge.net/rpcbind/rpcbind-0.2.1.tar.bz2
URL:        http://downloads.sourceforge.net/rpcbind
%description
 The rpcbind program is a replacement for portmap. It is required for import or export of Network File System (NFS) shared directories. 
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
sed -i "/servname/s:rpcbind:sunrpc:" src/rpcbind.c &&
sed -i "/error = getaddrinfo/s:rpcbind:sunrpc:" src/rpcinfo.c
./configure --prefix=/usr --bindir=/sbin --with-rpcuser=root &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-rpcbind DESTDIR=${RPM_BUILD_ROOT} 


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
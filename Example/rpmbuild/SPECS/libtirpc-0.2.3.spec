%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libtirpc package contains libraries that support programs that use the Remote Procedure Call (RPC) API. It replaces the RPC, but not the NIS library entries that used to be in glibc. 
Name:       libtirpc
Version:    0.2.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  pkg-config
Source0:    http://downloads.sourceforge.net/project/libtirpc/libtirpc/0.2.3/libtirpc-0.2.3.tar.bz2
Source1:    ftp://anduin.linuxfromscratch.org/other/rpcnis-headers.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/libtirpc-0.2.3-remove_nis-1.patch
URL:        http://downloads.sourceforge.net/project/libtirpc/libtirpc/0.2.3
%description
 The libtirpc package contains libraries that support programs that use the Remote Procedure Call (RPC) API. It replaces the RPC, but not the NIS library entries that used to be in glibc. 
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
if [ ! -r /usr/include/rpc/rpc.h ]; then
   tar -xvf  %_sourcedir/rpcnis-headers.tar.bz2 -C /usr/include
fi
patch -Np1 -i %_sourcedir/libtirpc-0.2.3-remove_nis-1.patch 
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac 
autoreconf -fi 
./configure --prefix=/usr --sysconfdir=/etc CFLAGS="-fPIC" 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install  DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libtirpc.so.* ${RPM_BUILD_ROOT}/lib 

ln -sfv ../../lib/libtirpc.so.1.0.10 ${RPM_BUILD_ROOT}/usr/lib/libtirpc.so


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
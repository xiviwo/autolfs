%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The xfsprogs package contains administration and debugging tools for the XFS file system. 
Name:       xfsprogs
Version:    3.1.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/x/xfsprogs-3.1.11.tar.gz
Source1:    ftp://oss.sgi.com/projects/xfs/cmd_tars/xfsprogs-3.1.11.tar.gz
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/x
%description
 The xfsprogs package contains administration and debugging tools for the XFS file system. 
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
make DEBUG=-DNDEBUG INSTALL_USER=root INSTALL_GROUP=root LOCAL_CONFIGURE_OPTIONS="--enable-readline" %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install install-dev && DESTDIR=${RPM_BUILD_ROOT} 

rm -rfv ${RPM_BUILD_ROOT}/lib/libhandle.{a,la,so} &&

ln -sfv ../../lib/libhandle.so.1 ${RPM_BUILD_ROOT}/usr/lib/libhandle.so &&

sed -i "s@libdir='/lib@libdir='/usr/lib@g" ${RPM_BUILD_ROOT}/usr/lib/libhandle.la


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
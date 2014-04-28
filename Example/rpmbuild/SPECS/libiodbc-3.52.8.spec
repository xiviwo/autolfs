%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libiodbc is an API to ODBC compatible databases. 
Name:       libiodbc
Version:    3.52.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Source0:    http://downloads.sourceforge.net/project/iodbc/iodbc/3.52.8/libiodbc-3.52.8.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/libiodbc-3.52.8-parallel_build-1.patch
URL:        http://downloads.sourceforge.net/project/iodbc/iodbc/3.52.8
%description
 libiodbc is an API to ODBC compatible databases. 
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
patch -Np1 -i %_sourcedir/libiodbc-3.52.8-parallel_build-1.patch &&
autoreconf -fiv &&
./configure --prefix=/usr --with-iodbc-inidir=/etc/iodbc --includedir=/usr/include/iodbc --disable-libodbc --disable-static                &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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
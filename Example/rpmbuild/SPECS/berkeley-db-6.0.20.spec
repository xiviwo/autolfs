%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Berkeley DB package contains programs and utilities used by many other applications for database related functions. 
Name:       berkeley-db
Version:    6.0.20
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://download.oracle.com/berkeley-db/db-6.0.20.tar.gz
URL:        http://download.oracle.com/berkeley-db
%description
 The Berkeley DB package contains programs and utilities used by many other applications for database related functions. 
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
cd build_unix                        &&
../dist/configure --prefix=/usr --enable-compat185 --enable-dbm --disable-static --enable-cxx       &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build_unix                        &&

mkdir -pv ${RPM_BUILD_ROOT}/usr/include
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/db-6.0.20
make docdir=${RPM_BUILD_ROOT}/usr/share/doc/db-6.0.20 install && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -v -R root:root /usr/bin/db_* /usr/include/db{,_185,_cxx}.h /usr/lib/libdb*.{so,la} /usr/share/doc/db-6.0.20
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
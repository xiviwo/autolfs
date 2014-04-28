%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The SQLite package is a software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine. 
Name:       sqlite
Version:    3.8.0.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sqlite.org/2013/sqlite-autoconf-3080002.tar.gz
Source1:    http://sqlite.org/2013/sqlite-doc-3080002.zip
URL:        http://sqlite.org/2013
%description
 The SQLite package is a software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine. 
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
unzip -q ../sqlite-doc-3080002.zip
./configure --prefix=/usr --disable-static CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_SECURE_DELETE=1" 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/sqlite-3.8.0.2
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/sqlite-3.8.0.2 

cp -v -R sqlite-doc-3080002/* ${RPM_BUILD_ROOT}/usr/share/doc/sqlite-3.8.0.2


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
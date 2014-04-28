%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The unixODBC package is an Open Source ODBC (Open DataBase Connectivity) sub-system and an ODBC SDK for Linux, Mac OSX, and UNIX. ODBC is an open specification for providing application developers with a predictable API with which to access data sources. Data sources include optional SQL Servers and any data source with an ODBC Driver. unixODBC contains the following components used to assist with the manipulation of ODBC data sources: a driver manager, an installer library and command line tool, command line tools to help install a driver and work with SQL, drivers and driver setup libraries. 
Name:       unixodbc
Version:    2.3.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.unixodbc.org/unixODBC-2.3.1.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/unixODBC-2.3.1.tar.gz
URL:        http://www.unixodbc.org
%description
 The unixODBC package is an Open Source ODBC (Open DataBase Connectivity) sub-system and an ODBC SDK for Linux, Mac OSX, and UNIX. ODBC is an open specification for providing application developers with a predictable API with which to access data sources. Data sources include optional SQL Servers and any data source with an ODBC Driver. unixODBC contains the following components used to assist with the manipulation of ODBC data sources: a driver manager, an installer library and command line tool, command line tools to help install a driver and work with SQL, drivers and driver setup libraries. 
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
./configure --prefix=/usr --sysconfdir=/etc/unixODBC 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install  DESTDIR=${RPM_BUILD_ROOT} 

find doc -name "Makefile*" -exec rm {} \; 
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/unixODBC-2.3.1 

cp -v -R doc/* ${RPM_BUILD_ROOT}/usr/share/doc/unixODBC-2.3.1


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod 644 doc/{lst,ProgrammerManual/Tutorial}/* 
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
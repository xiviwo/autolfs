%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Apache Portable Runtime Utility Library provides a predictable and consistent interface to underlying client library interfaces. This application programming interface assures predictable if not identical behaviour regardless of which libraries are available on a given platform. 
Name:       apr-util
Version:    1.5.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  apr
Requires:  openssl
Source0:    http://archive.apache.org/dist/apr/apr-util-1.5.2.tar.bz2
URL:        http://archive.apache.org/dist/apr
%description
 The Apache Portable Runtime Utility Library provides a predictable and consistent interface to underlying client library interfaces. This application programming interface assures predictable if not identical behaviour regardless of which libraries are available on a given platform. 
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
./configure --prefix=/usr --with-apr=/usr --with-gdbm=/usr --with-openssl=/usr --with-crypto 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Apache Portable Runtime (APR) is a supporting library for the Apache web server. It provides a set of application programming interfaces (APIs) that map to the underlying Operating System (OS). Where the OS doesn't support a particular function, APR will provide an emulation. Thus programmers can use the APR to make a program portable across different platforms. 
Name:       apr
Version:    1.4.8
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://archive.apache.org/dist/apr/apr-1.4.8.tar.bz2
Source1:    ftp://ftp.mirrorservice.org/sites/ftp.apache.org/apr/apr-1.4.8.tar.bz2
URL:        http://archive.apache.org/dist/apr
%description
 The Apache Portable Runtime (APR) is a supporting library for the Apache web server. It provides a set of application programming interfaces (APIs) that map to the underlying Operating System (OS). Where the OS doesn't support a particular function, APR will provide an emulation. Thus programmers can use the APR to make a program portable across different platforms. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


./configure --prefix=${RPM_BUILD_ROOT}/usr --disable-static --with-installbuilddir=${RPM_BUILD_ROOT}/usr/share/apr-1/build 
make
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
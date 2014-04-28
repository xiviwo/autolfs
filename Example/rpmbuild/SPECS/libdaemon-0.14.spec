%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libdaemon package is a lightweight C library that eases the writing of UNIX daemons. 
Name:       libdaemon
Version:    0.14
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz
URL:        http://0pointer.de/lennart/projects/libdaemon
%description
 The libdaemon package is a lightweight C library that eases the writing of UNIX daemons. 
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
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docdir=${RPM_BUILD_ROOT}/usr/share/doc/libdaemon-0.14 install DESTDIR=${RPM_BUILD_ROOT} 


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
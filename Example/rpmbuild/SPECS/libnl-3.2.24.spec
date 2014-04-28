%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libnl suite is a collection of libraries providing APIs to netlink protocol based Linux kernel interfaces. 
Name:       libnl
Version:    3.2.24
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.carisma.slowglass.com/~tgr/libnl/files/libnl-3.2.24.tar.gz
URL:        http://www.carisma.slowglass.com/~tgr/libnl/files
%description
 The libnl suite is a collection of libraries providing APIs to netlink protocol based Linux kernel interfaces. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-static &&
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
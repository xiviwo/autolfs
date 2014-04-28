%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The pkg-config package contains a tool for passing the include path and/or library paths to build tools during the configure and make file execution. 
Name:       pkg-config
Version:    0.28
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz

URL:        http://pkgconfig.freedesktop.org/releases
%description
 The pkg-config package contains a tool for passing the include path and/or library paths to build tools during the configure and make file execution. 
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
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config-0.28
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
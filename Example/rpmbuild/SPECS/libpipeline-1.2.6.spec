%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Libpipeline package contains a library for manipulating pipelines of subprocesses in a flexible and convenient way. 
Name:       libpipeline
Version:    1.2.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.2.6.tar.gz

URL:        http://download.savannah.gnu.org/releases/libpipeline
%description
 The Libpipeline package contains a library for manipulating pipelines of subprocesses in a flexible and convenient way. 
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
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
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
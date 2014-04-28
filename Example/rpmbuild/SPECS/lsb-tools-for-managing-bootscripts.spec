%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The initd-tools package contains programs to install and remove LSB based bootscripts. 
Name:       lsb-tools-for-managing-bootscripts
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://people.freedesktop.org/~dbn/initd-tools/releases/initd-tools-0.1.3.tar.gz
URL:        http://people.freedesktop.org/~dbn/initd-tools/releases
%description
 The initd-tools package contains programs to install and remove LSB based bootscripts. 
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
./configure --prefix=/usr 
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
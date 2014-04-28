%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Sysvinit package contains programs for controlling the startup, running, and shutdown of the system. 
Name:       sysvinit
Version:    2.88dsf
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.88dsf.tar.bz2

URL:        http://download.savannah.gnu.org/releases/sysvinit
%description
 The Sysvinit package contains programs for controlling the startup, running, and shutdown of the system. 
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
patch -Np1 -i %_sourcedir/sysvinit-2.88dsf-consolidated-1.patch
make -C src %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make -C src install ROOT=${RPM_BUILD_ROOT}  DESTDIR=${RPM_BUILD_ROOT} 


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
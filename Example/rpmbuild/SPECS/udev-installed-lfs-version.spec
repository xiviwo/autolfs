%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Udev was indeed installed in LFS and there is no reason to reinstall it unless you are going to install a package such as UPower. This installation of Udev enables extra features which includes gudev, a requirement for UPower and optionally used by other packages. 
Name:       udev-installed-lfs-version
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  acl
Requires:  glib
Requires:  gperf
Requires:  pciutils
Requires:  usbutils
Source0:    http://www.freedesktop.org/software/systemd/systemd-206.tar.xz

URL:        http://www.freedesktop.org/software/systemd
%description
 Udev was indeed installed in LFS and there is no reason to reinstall it unless you are going to install a package such as UPower. This installation of Udev enables extra features which includes gudev, a requirement for UPower and optionally used by other packages. 
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
./configure --prefix=/usr --sysconfdir=/etc --sbindir=/sbin --with-rootlibdir=/lib --libexecdir=/lib --with-systemdsystemunitdir=no --disable-introspection --docdir=/usr/share/doc/<udev-Installed LFS Version> 
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
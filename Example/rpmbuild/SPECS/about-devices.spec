export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    about-devices
Name:       about-devices
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/postlfs/devices.html
%description
about-devices
%pre
%prep
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

mkdir -pv $RPM_BUILD_ROOT/dev
mkdir -pv $RPM_BUILD_ROOT/etc/rc.d/rcS.d/
mkdir -pv $RPM_BUILD_ROOT/mnt
mkdir -pv $RPM_BUILD_ROOT/
mount --bind ${RPM_BUILD_ROOT}/ ${RPM_BUILD_ROOT}/mnt
cp -a ${RPM_BUILD_ROOT}/dev/* ${RPM_BUILD_ROOT}/mnt/dev
rm ${RPM_BUILD_ROOT}/etc/rc.d/rcS.d/{S10udev,S50udev_retry}
umount ${RPM_BUILD_ROOT}/mnt

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
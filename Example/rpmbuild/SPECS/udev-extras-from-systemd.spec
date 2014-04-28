%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     In 2012, the Udev code distribution was merged with systemd. Systemd is a set of programs that replace the SysVInit package used by LFS and is much more complex. It is not compatible with the LFS bootscripts and has many problems and few advantages for most LFS users. 
Name:       udev-extras-from-systemd
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  gperf
Requires:  gobject-introspection
Source0:    http://www.freedesktop.org/software/systemd/systemd-208.tar.xz

URL:        http://www.freedesktop.org/software/systemd
%description
 In 2012, the Udev code distribution was merged with systemd. Systemd is a set of programs that replace the SysVInit package used by LFS and is much more complex. It is not compatible with the LFS bootscripts and has many problems and few advantages for most LFS users. 
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
UDEV=208-3
tar -xf  %_sourcedir/udev-lfs-$UDEV.tar.bz2
make -f udev-lfs-$UDEV/Makefile.lfs keymap %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make -f udev-lfs-$UDEV/Makefile.lfs install-keymap DESTDIR=${RPM_BUILD_ROOT} 

make -f udev-lfs-$UDEV/Makefile.lfs gudev
make -f udev-lfs-$UDEV/Makefile.lfs install-gudev DESTDIR=${RPM_BUILD_ROOT} 

make -f udev-lfs-$UDEV/Makefile.lfs gir-data
make -f udev-lfs-$UDEV/Makefile.lfs install-gir-data DESTDIR=${RPM_BUILD_ROOT} 


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
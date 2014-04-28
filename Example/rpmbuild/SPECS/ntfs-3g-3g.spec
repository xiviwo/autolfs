%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Ntfs-3g package contains an open source, driver for Windows NTFS file system. This can mount Windows partitions so that they are writeable and allows you edit or delete Windows files from Linux. 
Name:       ntfs-3g
Version:    3g
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://tuxera.com/opensource/ntfs-3g_ntfsprogs-2013.1.13.tgz
URL:        http://tuxera.com/opensource
%description
 The Ntfs-3g package contains an open source, driver for Windows NTFS file system. This can mount Windows partitions so that they are writeable and allows you edit or delete Windows files from Linux. 
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

mkdir -pv ${RPM_BUILD_ROOT}/sbin
mkdir -pv ${RPM_BUILD_ROOT}/mnt
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man8/
make install && DESTDIR=${RPM_BUILD_ROOT} 

ln -svf  %_sourcedir/bin/ntfs-3g ${RPM_BUILD_ROOT}/sbin/mount.ntfs &&

ln -svf /usr/share/man/man8/{ntfs-3g,mount.ntfs}.8


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 4755 /sbin/mount.ntfs

chmod -v 777 /mnt/usb
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
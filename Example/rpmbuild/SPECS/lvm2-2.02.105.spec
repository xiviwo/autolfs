%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The LVM2 package is a package that manages logical partitions. It allows spanning of file systems across multiple physical disks and disk partitions and provides for dynamic growing or shrinking of logical partitions. 
Name:       lvm2
Version:    2.02.105
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.105.tgz
URL:        ftp://sources.redhat.com/pub/lvm2
%description
 The LVM2 package is a package that manages logical partitions. It allows spanning of file systems across multiple physical disks and disk partitions and provides for dynamic growing or shrinking of logical partitions. 
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
./configure --prefix=/usr --exec-prefix= --with-confdir=/etc --enable-applib --enable-cmdlib --enable-pkgconfig --enable-udev_sync &&
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
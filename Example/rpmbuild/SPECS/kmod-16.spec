%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Kmod package contains libraries and utilities for loading kernel modules 
Name:       kmod
Version:    16
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-16.tar.xz

URL:        http://www.kernel.org/pub/linux/utils/kernel/kmod
%description
 The Kmod package contains libraries and utilities for loading kernel modules 
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
./configure --prefix=/usr --bindir=/bin --sysconfdir=/etc --with-rootlibdir=/lib --disable-manpages --with-xz --with-zlib
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/sbin
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

make -C man install DESTDIR=${RPM_BUILD_ROOT} 

for target in depmod insmod modinfo modprobe rmmod; do
  ln -svf  %_sourcedir/bin/kmod ${RPM_BUILD_ROOT}/sbin/$target

done
ln -svf kmod ${RPM_BUILD_ROOT}/bin/lsmod


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
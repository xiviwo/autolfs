%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libdrm provides core library routines for the X Window System to directly interface with video hardware using the Linux kernel's Direct Rendering Manager (DRM). 
Name:       libdrm
Version:    2.4.46
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-libraries
Source0:    http://dri.freedesktop.org/libdrm/libdrm-2.4.46.tar.bz2
URL:        http://dri.freedesktop.org/libdrm
%description
 libdrm provides core library routines for the X Window System to directly interface with video hardware using the Linux kernel's Direct Rendering Manager (DRM). 
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
sed -e "/pthread-stubs/d" -i configure.ac 
autoreconf -fi 
./configure --prefix=/usr --enable-udev 
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
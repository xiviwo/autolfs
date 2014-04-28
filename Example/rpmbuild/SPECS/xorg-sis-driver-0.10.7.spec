%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xorg Drivers page contains the instructions for building Xorg drivers that are necessary in order for Xorg Server to take the advantage of the hardware that it is running on. At least one input and one video driver is required for Xorg Server to start. 
Name:       xorg-sis-driver
Version:    0.10.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-server
Source0:    http://xorg.freedesktop.org/archive/individual/driver/xf86-video-sis-0.10.7.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/driver/xf86-video-sis-0.10.7.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/xf86-video-sis-0.10.7-upstream_fixes-1.patch
URL:        http://xorg.freedesktop.org/archive/individual/driver
%description
 The Xorg Drivers page contains the instructions for building Xorg drivers that are necessary in order for Xorg Server to take the advantage of the hardware that it is running on. At least one input and one video driver is required for Xorg Server to start. 
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
patch -Np1 -i %_sourcedir/xf86-video-sis-0.10.7-upstream_fixes-1.patch &&
./configure $XORG_CONFIG &&
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
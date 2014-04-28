%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xorg Drivers page contains the instructions for building Xorg drivers that are necessary in order for Xorg Server to take the advantage of the hardware that it is running on. At least one input and one video driver is required for Xorg Server to start. 
Name:       xorg-r128-driver
Version:    6.9.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-server
Source0:    http://xorg.freedesktop.org/archive/individual/driver/xf86-video-r128-6.9.1.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/driver/xf86-video-r128-6.9.1.tar.bz2
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
./configure $XORG_CONFIG 
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
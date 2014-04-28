%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xorg Drivers page contains the instructions for building Xorg drivers that are necessary in order for Xorg Server to take the advantage of the hardware that it is running on. At least one input and one video driver is required for Xorg Server to start. 
Name:       glamor-egl
Version:    0.5.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-server
Source0:    http://anduin.linuxfromscratch.org/sources/other/glamor-egl-0.5.0.tar.xz
Source1:    ftp://anduin.linuxfromscratch.org/other/glamor-egl-0.5.0.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/glamor-egl-0.5.0-fixes-1.patch
URL:        http://anduin.linuxfromscratch.org/sources/other
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
patch -Np1 -i %_sourcedir/glamor-egl-0.5.0-fixes-1.patch 
autoreconf -fi 
./configure $XORG_CONFIG --enable-glx-tls 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ALSA Plugins package contains plugins for various audio libraries and sound servers. 
Name:       alsa-plugins
Version:    1.0.27
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Source0:    http://alsa.cybermirror.org/plugins/alsa-plugins-1.0.27.tar.bz2
Source1:    ftp://ftp.alsa-project.org/pub/plugins/alsa-plugins-1.0.27.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/alsa-plugins-1.0.27-ffmpeg2-1.patch
URL:        http://alsa.cybermirror.org/plugins
%description
 The ALSA Plugins package contains plugins for various audio libraries and sound servers. 
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
patch -Np1 -i %_sourcedir/alsa-plugins-1.0.27-ffmpeg2-1.patch &&
./configure &&
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
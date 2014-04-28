%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xine Libraries package contains xine libraries. These are useful for interfacing with external plug-ins that allow the flow of information from the source to the audio and video hardware. 
Name:       xine-lib
Version:    1.2.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Requires:  ffmpeg
Requires:  alsa
Requires:  pulseaudio
Source0:    http://downloads.sourceforge.net/xine/xine-lib-1.2.3.tar.xz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-lib-1.2.3.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/xine-lib-1.2.3-missing_include-1.patch
URL:        http://downloads.sourceforge.net/xine
%description
 The Xine Libraries package contains xine libraries. These are useful for interfacing with external plug-ins that allow the flow of information from the source to the audio and video hardware. 
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
patch -Np1 -i %_sourcedir/xine-lib-1.2.3-missing_include-1.patch 
./configure --prefix=/usr --disable-vcd --disable-modplug --docdir=/usr/share/doc/xine-lib-1.2.3 
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
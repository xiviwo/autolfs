%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libao package contains a cross-platform audio library. This is useful to output audio on a wide variety of platforms. It currently supports WAV files, OSS (Open Sound System), ESD (Enlighten Sound Daemon), ALSA (Advanced Linux Sound Architecture), NAS (Network Audio system), aRTS (analog Real-Time Synthesizer and PulseAudio (next generation GNOME sound architecture). 
Name:       libao
Version:    1.1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.xiph.org/releases/ao/libao-1.1.0.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libao-1.1.0.tar.gz
URL:        http://downloads.xiph.org/releases/ao
%description
 The libao package contains a cross-platform audio library. This is useful to output audio on a wide variety of platforms. It currently supports WAV files, OSS (Open Sound System), ESD (Enlighten Sound Daemon), ALSA (Advanced Linux Sound Architecture), NAS (Network Audio system), aRTS (analog Real-Time Synthesizer and PulseAudio (next generation GNOME sound architecture). 
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
./configure --prefix=/usr 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 README ${RPM_BUILD_ROOT}/usr/share/doc/libao-1.1.0


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
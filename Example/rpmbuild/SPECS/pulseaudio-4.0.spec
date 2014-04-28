%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for sound applications. It allows you to do advanced operations on your sound data as it passes between your application and your hardware. Things like transferring the audio to a different machine, changing the sample format or channel count and mixing several sounds into one are easily achieved using a sound server. 
Name:       pulseaudio
Version:    4.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  intltool
Requires:  json-c
Requires:  libsndfile
Requires:  alsa-lib
Requires:  d-bus
Requires:  libcap
Requires:  openssl
Requires:  speex
Requires:  xorg-libraries
Source0:    http://freedesktop.org/software/pulseaudio/releases/pulseaudio-4.0.tar.xz
URL:        http://freedesktop.org/software/pulseaudio/releases
%description
 PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for sound applications. It allows you to do advanced operations on your sound data as it passes between your application and your hardware. Things like transferring the audio to a different machine, changing the sample format or channel count and mixing several sounds into one are easily achieved using a sound server. 
%pre
groupadd -g 58 pulse  || :

groupadd -g 59 pulse-access  || :

useradd -c "Pulseaudio User" -d /var/run/pulse -g pulse -s /bin/false -u 58 pulse  || :

usermod -a -G audio pulse || :
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
find . -name "Makefile.in" | xargs sed -i "s|(libdir)/@PACKAGE@|(libdir)/pulse|" &&
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-module-dir=/usr/lib/pulse/modules &&
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
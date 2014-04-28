%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     FFmpeg is a solution to record, convert and stream audio and video. It is a very fast video and audio converter and it can also acquire from a live audio/video source. Designed to be intuitive, the command-line interface (ffmpeg) tries to figure out all the parameters, when possible. FFmpeg can also convert from any sample rate to any other, and resize video on the fly with a high quality polyphase filter. FFmpeg can use a Video4Linux compatible video source and any Open Sound System audio source. 
Name:       ffmpeg
Version:    1.2.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  faac
Requires:  freetype
Requires:  lame
Requires:  openjpeg
Requires:  pulseaudio
Requires:  speex
Requires:  libtheora
Requires:  libvorbis
Requires:  libvpx
Requires:  xvid
Requires:  openssl
Requires:  sdl
Requires:  xorg-libraries
Requires:  yasm
Source0:    http://ffmpeg.org/releases/ffmpeg-1.2.2.tar.bz2
URL:        http://ffmpeg.org/releases
%description
 FFmpeg is a solution to record, convert and stream audio and video. It is a very fast video and audio converter and it can also acquire from a live audio/video source. Designed to be intuitive, the command-line interface (ffmpeg) tries to figure out all the parameters, when possible. FFmpeg can also convert from any sample rate to any other, and resize video on the fly with a high quality polyphase filter. FFmpeg can use a Video4Linux compatible video source and any Open Sound System audio source. 
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
export LIBRARY_PATH=$XORG_PREFIX/lib
sed -i 's/-lflite"/-lflite -lasound"/' configure 
./configure --prefix=/usr --enable-gpl --enable-version3 --enable-nonfree --disable-static --enable-shared --enable-x11grab --enable-libfaac --enable-libfreetype --enable-libmp3lame --enable-libopenjpeg --enable-libpulse --enable-libspeex --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libxvid --enable-openssl --disable-debug      
make %{?_smp_mflags} 

gcc tools/qt-faststart.c -o tools/qt-faststart 
unset LIBRARY_PATH

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755    tools/qt-faststart ${RPM_BUILD_ROOT}/usr/bin 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/ffmpeg-1.2.2 

install -v -m644    doc/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/ffmpeg-1.2.2

install -v -m644 doc/*.html ${RPM_BUILD_ROOT}/usr/share/doc/ffmpeg-1.2.2


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
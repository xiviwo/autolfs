%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Transcode is a fast, versatile and command-line based audio/video everything to everything converter. For a rundown of the features and capabilities, along with usage examples, visit the Transcode Wiki at http://www.transcoding.org/. 
Name:       transcode
Version:    1.1.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  ffmpeg
Requires:  alsa-lib
Requires:  lame
Requires:  libdvdread
Requires:  libmpeg2
Requires:  xorg-libraries
Source0:    https://bitbucket.org/france/transcode-tcforge/downloads/transcode-1.1.7.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/transcode-1.1.7.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/transcode-1.1.7-ffmpeg2-1.patch
URL:        https://bitbucket.org/france/transcode-tcforge/downloads
%description
 Transcode is a fast, versatile and command-line based audio/video everything to everything converter. For a rundown of the features and capabilities, along with usage examples, visit the Transcode Wiki at http://www.transcoding.org/. 
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
sed -i "s:#include <freetype/ftglyph.h>:#include FT_GLYPH_H:" filter/subtitler/load_font.c
sed -i 's|doc/transcode|&-$(PACKAGE_VERSION)|' $(find . -name Makefile.in -exec grep -l 'docsdir =' {} \;) &&
patch -Np1 -i %_sourcedir/transcode-1.1.7-ffmpeg2-1.patch &&
./configure --prefix=/usr --enable-alsa --enable-libmpeg2 &&
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
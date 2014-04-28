%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     VLC is a media player, streamer, and encoder. It can play from many inputs like files, network streams, capture device, desktops, or DVD, SVCD, VCD, and audio CD. It can play most audio and video codecs (MPEG 1/2/4, H264, VC-1, DivX, WMV, Vorbis, AC3, AAC, etc.), but can also convert to different formats and/or send streams through the network. 
Name:       vlc
Version:    2.1.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  lua
Requires:  libmad
Requires:  ffmpeg
Requires:  liba52
Requires:  x-window-system-environment
Requires:  alsa-lib
Requires:  libgcrypt
Source0:    http://download.videolan.org/pub/videolan/vlc/2.1.3/vlc-2.1.3.tar.xz
Source1:    ftp://ftp.videolan.org/pub/videolan/vlc/2.1.3/vlc-2.1.3.tar.xz
URL:        http://download.videolan.org/pub/videolan/vlc/2.1.3
%description
 VLC is a media player, streamer, and encoder. It can play from many inputs like files, network streams, capture device, desktops, or DVD, SVCD, VCD, and audio CD. It can play most audio and video codecs (MPEG 1/2/4, H264, VC-1, DivX, WMV, Vorbis, AC3, AAC, etc.), but can also convert to different formats and/or send streams through the network. 
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
sed -i 's:libsmbclient.h:samba-4.0/&:' modules/access/smb.c &&
./bootstrap                                                 &&
./configure --prefix=/usr                                   &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docdir=${RPM_BUILD_ROOT}/usr/share/doc/vlc-2.1.3 install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
gtk-update-icon-cache &&

update-desktop-database
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
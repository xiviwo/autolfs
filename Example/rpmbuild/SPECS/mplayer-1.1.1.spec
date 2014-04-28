%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     MPlayer is a powerful audio/video player controlled via the command line or a graphical interface that is able to play almost every popular audio and video file format. With supported video hardware and additional drivers, MPlayer can play video files without an X Window System installed. 
Name:       mplayer
Version:    1.1.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  yasm
Requires:  gtk
Requires:  libvdpau
Source0:    http://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.1.tar.xz
Source1:    ftp://ftp.mplayerhq.hu/MPlayer/releases/MPlayer-1.1.1.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/MPlayer-1.1.1-giflib_fixes-1.patch
Source3:    http://www.linuxfromscratch.org/patches/blfs/7.5/MPlayer-1.1.1-live_fixes-1.patch
Source4:    http://www.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2
Source5:    ftp://ftp.mplayerhq.hu/MPlayer/skins/Clearlooks-1.5.tar.bz2
URL:        http://www.mplayerhq.hu/MPlayer/releases
%description
 MPlayer is a powerful audio/video player controlled via the command line or a graphical interface that is able to play almost every popular audio and video file format. With supported video hardware and additional drivers, MPlayer can play video files without an X Window System installed. 
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
patch -Np1 -i %_sourcedir/MPlayer-1.1.1-giflib_fixes-1.patch &&
patch -Np1 -i %_sourcedir/MPlayer-1.1.1-live_fixes-1.patch &&
sed -i 's:libsmbclient.h:samba-4.0/&:' configure stream/stream_smb.c &&
./configure --prefix=/usr --confdir=/etc/mplayer --enable-dynamic-plugins --enable-menu --enable-gui             &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/mplayer
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/mplayer/skins
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/mplayer-1.1.1 &&

install -v -m644    DOCS/HTML/en/* ${RPM_BUILD_ROOT}/usr/share/doc/mplayer-1.1.1

install -v -m644 etc/codecs.conf ${RPM_BUILD_ROOT}/etc/mplayer

install -v -m644 etc/*.conf ${RPM_BUILD_ROOT}/etc/mplayer

tar -xvf  %_sourcedir/Clearlooks-1.5.tar.bz2 -C ${RPM_BUILD_ROOT}/usr/share/mplayer/skins &&

ln -sfv Clearlooks ${RPM_BUILD_ROOT}/usr/share/mplayer/skins/default


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
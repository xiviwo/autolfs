%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Firefox is a stand-alone browser based on the Mozilla codebase. 
Name:       firefox
Version:    23.0.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Requires:  gtk
Requires:  zip
Requires:  unzip
Requires:  libevent
Requires:  libvpx
Requires:  nspr
Requires:  nss
Requires:  sqlite
Requires:  yasm
Source0:    http://releases.mozilla.org/pub/mozilla.org/firefox/releases/23.0.1/source/firefox-23.0.1.source.tar.bz2
Source1:    ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/23.0.1/source/firefox-23.0.1.source.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/firefox-23.0.1-search_box_fix-1.patch
Source3:    http://www.linuxfromscratch.org/patches/blfs/svn/firefox-23.0.1-system_cairo-1.patch
URL:        http://releases.mozilla.org/pub/mozilla.org/firefox/releases/23.0.1/source
%description
 Firefox is a stand-alone browser based on the Mozilla codebase. 
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
cat > mozconfig << "EOF"
# If you have a multicore machine, firefox will now use all the cores by
# default. Exceptionally, you can reduce the number of cores, e.g. to 1,
# by uncommenting the next line and setting a valid number of CPU cores.
#mk_add_options MOZ_MAKE_FLAGS="-j1"
# If you have installed DBus-Glib comment out this line:
ac_add_options --disable-dbus
# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi
# If you have installed libnotify comment out this line:
ac_add_options --disable-libnotify
# Uncomment these lines if you have installed optional dependencies:
# GStreamer is necessary for H.264 video playback in HTML5 Video Player
#ac_add_options --enable-gstreamer
#ac_add_options --enable-system-hunspell
#ac_add_options --enable-startup-notification
# Uncomment this line if you compiled Cairo with --enable-tee switch and want
# to use it instead of the bundled one:
#ac_add_options --enable-system-cairo
# If you have not installed Yasm then uncomment this line:
#ac_add_options --disable-webm
# If you have installed xulrunner uncomment the next two ac_add_options lines
# and check that the sdk will be set by running pkg-config in a subshell
# and has not become hardcoded or empty when you created this file
#ac_add_options --with-system-libxul
#ac_add_options --with-libxul-sdk=$(pkg-config --variable=sdkdir libxul)
# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss
# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr
ac_add_options --enable-application=browser
ac_add_options --disable-crashreporter
ac_add_options --disable-installer
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options --enable-install-strip
ac_add_options --enable-gio
ac_add_options --enable-official-branding
ac_add_options --enable-safe-browsing
ac_add_options --enable-url-classifier
ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman
ac_add_options --with-pthreads
ac_add_options --with-system-bz2
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-build-dir
EOF
patch -Np1 -i %_sourcedir/firefox-23.0.1-search_box_fix-1.patch
patch -Np1 -i %_sourcedir/firefox-23.0.1-system_cairo-1.patch
sed -i 's@ ""@@' browser/base/Makefile.in 
make -f client.mk %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1/browser/icons
mkdir -pv ${RPM_BUILD_ROOT}/usr/include/npapi
make -C firefox-build-dir/browser/installer DESTDIR=${RPM_BUILD_ROOT} 

rm -rf ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1 

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1 

tar -xvf firefox-build-dir/dist/firefox-23.0.1.en-US.linux-$(uname -m).tar.bz2 -C ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1 --strip-components=1 

ln -sfv ../lib/firefox-23.0.1/firefox ${RPM_BUILD_ROOT}/usr/bin 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins 

ln -sfv ../mozilla/plugins ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1

make -C firefox-build-dir install  DESTDIR=${RPM_BUILD_ROOT} 

ln -sfv ../lib/firefox-23.0.1/firefox ${RPM_BUILD_ROOT}/usr/bin 

ln -sfv ../xulrunner-23.0.1 ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1/xulrunner 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins 

ln -sfv ../mozilla/plugins ${RPM_BUILD_ROOT}/usr/lib/firefox-23.0.1

rm -rf ${RPM_BUILD_ROOT}/usr/include/npapi 

mkdir -pv ${RPM_BUILD_ROOT}/usr/include/npapi 

cp -v dom/plugins/base/*.h ${RPM_BUILD_ROOT}/usr/include/npapi

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/applications 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps 

cat > /usr/share/applications/firefox.desktop << "EOF" 
[Desktop Entry]
Encoding=UTF-8
Name=Firefox Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=firefox %u
Terminal=false
Type=Application
Icon=firefox
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF
ln -sfv /usr/lib/firefox-23.0.1/browser/icons/mozicon128.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/firefox.png


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R -v root:root /usr/lib/firefox-23.0.1 
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
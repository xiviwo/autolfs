%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Thunderbird is a stand-alone mail/news client based on the Mozilla codebase. It uses the Gecko rendering engine to enable it to display and compose HTML emails. 
Name:       thunderbird
Version:    24.3.0
Release:    %{?dist}7.5
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
Source0:    http://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/24.3.0/source/thunderbird-24.3.0.source.tar.bz2
Source1:    ftp://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/24.3.0/source/thunderbird-24.3.0.source.tar.bz2
URL:        http://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/24.3.0/source
%description
 Thunderbird is a stand-alone mail/news client based on the Mozilla codebase. It uses the Gecko rendering engine to enable it to display and compose HTML emails. 
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
# If you have a multicore machine you can speed up the build by running
# several jobs at once by uncommenting the following line and setting the
# value to number of CPU cores:
#mk_add_options MOZ_MAKE_FLAGS="-j4"
# If you have installed DBus-Glib comment out this line:
ac_add_options --disable-dbus
# If you have installed wireless-tools comment out this line:
ac_add_options --disable-necko-wifi
# If you have installed libnotify comment out this line:
ac_add_options --disable-libnotify
# GStreamer is necessary for H.264 video playback in HTML5 Video Player;
# to be enabled, also remember to set "media.gstreamer.enabled" to "true"
# in about:config. If you have installed GStreamer comment out this line:
ac_add_options --disable-gstreamer
# Uncomment these lines if you have installed optional dependencies:
#ac_add_options --enable-system-hunspell
#ac_add_options --enable-startup-notification
# Uncomment this line if you compiled Cairo with --enable-tee switch and want
# to use it instead of the bundled one:
#ac_add_options --enable-system-cairo
# If you have not installed Yasm then uncomment this line:
#ac_add_options --disable-webm
# If you want to compile the Mozilla Calendar, uncomment this line:
#ac_add_options --enable-calendar
# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss
# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr
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
mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/thunderbuild
EOF

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/thunderbird-24.3.0/chrome/icons/default
make -f client.mk &&
make -C thunderbuild/mail/installer DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/thunderbird-24.3.0 &&

tar -xvf thunderbuild/mozilla/dist/thunderbird-24.3.0.en-US.linux-$(uname -m).tar.bz2 -C ${RPM_BUILD_ROOT}/usr/lib/thunderbird-24.3.0 --strip-components=1 &&

ln -sfv ../lib/thunderbird-24.3.0/thunderbird ${RPM_BUILD_ROOT}/usr/bin

make -C thunderbuild install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/applications &&

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps &&

cat > /usr/share/applications/thunderbird.desktop << "EOF" &&
[Desktop Entry]
Encoding=UTF-8
Name=Thunderbird Mail
Comment=Send and receive mail with Thunderbird
GenericName=Mail Client
Exec=thunderbird %u
Terminal=false
Type=Application
Icon=thunderbird
Categories=Application;Network;Email;
MimeType=application/xhtml+xml;text/xml;application/xhtml+xml;application/xml;application/rss+xml;x-scheme-handler/mailto;
StartupNotify=true
EOF
ln -sfv /usr/lib/thunderbird-24.3.0/chrome/icons/default/default256.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/thunderbird.png


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
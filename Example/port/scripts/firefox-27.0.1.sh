#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=firefox
version=27.0.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/27.0.1/source/firefox-27.0.1.source.tar.bz2
nwget ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/27.0.1/source/firefox-27.0.1.source.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" firefox-27.0.1.source.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
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

sed -i 's@ ""@@' browser/base/Makefile.in 
make -f client.mk

make -C firefox-build-dir/browser/installer

rm -rf /usr/lib/firefox-27.0.1 
mkdir -pv /usr/lib/firefox-27.0.1 

tar -xvf firefox-build-dir/dist/firefox-27.0.1.en-US.linux-$(uname -m).tar.bz2 -C /usr/lib/firefox-27.0.1 --strip-components=1 
chown -R -v root:root /usr/lib/firefox-27.0.1 

ln -sfv ../lib/firefox-27.0.1/firefox /usr/bin 

mkdir -pv -pv /usr/lib/mozilla/plugins 
ln -sfv ../mozilla/plugins /usr/lib/firefox-27.0.1

make -C firefox-build-dir install 
ln -sfv ../lib/firefox-27.0.1/firefox /usr/bin 
ln -sfv ../xulrunner-27.0.1 /usr/lib/firefox-27.0.1/xulrunner 

mkdir -pv -pv /usr/lib/mozilla/plugins 
ln -sfv ../mozilla/plugins /usr/lib/firefox-27.0.1

mkdir -pv -pv /usr/share/applications 
mkdir -pv -pv /usr/share/pixmaps 

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

ln -sfv /usr/lib/firefox-27.0.1/browser/icons/mozicon128.png /usr/share/pixmaps/firefox.png


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

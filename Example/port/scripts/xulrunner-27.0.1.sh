#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xulrunner
version=27.0.1
export MAKEFLAGS='-j 4'
download()
{
nwget http:///ftp.mozilla.org/pub/mozilla.org/firefox/releases/27.0.1/source/firefox-27.0.1.source.tar.bz2
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

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --enable-system-sqlite
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss

# It is recommended not to touch anything below this line
ac_add_options --prefix=/usr
ac_add_options --enable-application=xulrunner

ac_add_options --disable-crashreporter
ac_add_options --disable-installer
ac_add_options --disable-updater
ac_add_options --disable-debug
ac_add_options --disable-tests
ac_add_options --disable-mochitest

ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options --enable-install-strip

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --enable-shared-js
ac_add_options --with-pthreads

ac_add_options --with-system-bz2
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/xulrunner-build-dir
EOF

make -f client.mk

make -C xulrunner-build-dir install 

mkdir -pv -pv /usr/lib/mozilla/plugins 
rm -rf /usr/lib/xulrunner-27.0.1/plugins 
ln -svf ../mozilla/plugins /usr/lib/xulrunner-27.0.1 

chmod -v 755 /usr/lib/xulrunner-devel-27.0.1/sdk/bin/xpcshell 

for library in libmozalloc.so libmozjs.so libxul.so; do
    ln -sfv ../../../xulrunner-27.0.1/$library /usr/lib/xulrunner-devel-27.0.1/sdk/lib/$library
    ln -sfv xulrunner-27.0.1/$library /usr/lib/$library
done

ln -sfv ../xulrunner-devel-27.0.1/sdk/bin/run-mozilla.sh /usr/lib/xulrunner-27.0.1
ln -sfv ../xulrunner-devel-27.0.1/sdk/bin/xpcshell /usr/lib/xulrunner-27.0.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

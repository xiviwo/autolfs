#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=seamonkey
version=2.24
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.mozilla.org/pub/mozilla.org/seamonkey/releases/2.24/source/seamonkey-2.24.source.tar.bz2
nwget http://ftp.mozilla.org/pub/mozilla.org/seamonkey/releases/2.24/source/seamonkey-2.24.source.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" seamonkey-2.24.source.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cat > mozconfig << EOF
# If you have a multicore machine you can speed up the build by running
# several jobs at once, but if you have a single core, delete this line:
mk_add_options MOZ_MAKE_FLAGS="-j$(getconf _NPROCESSORS_ONLN)"

# If you have installed Yasm delete this option:
ac_add_options --disable-webm

# If you have installed DBus-Glib delete this option:
ac_add_options --disable-dbus

# If you have installed wireless-tools delete this option:
ac_add_options --disable-necko-wifi

# If you have installed libnotify delete this option:
ac_add_options --disable-libnotify

# GStreamer is necessary for H.264 video playback in HTML5 Video Player;
# to be enabled, also remember to set "media.gstreamer.enabled" to "true"
# in about:config. If you have installed GStreamer comment out this line:
ac_add_options --disable-gstreamer

# Uncomment this line if you compiled Cairo with --enable-tee switch and want
# to use it instead of the bundled one:
#ac_add_options --enable-system-cairo

# Uncomment these if you have installed them:
# ac_add_options --enable-startup-notification
# ac_add_options --enable-system-hunspell
# ac_add_options --enable-system-sqlite
# ac_add_options --with-system-libevent
# ac_add_options --with-system-libvpx
# ac_add_options --with-system-nspr
# ac_add_options --with-system-nss

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/moz-build-dir
ac_add_options --disable-crashreporter
ac_add_options --disable-debug
ac_add_options --disable-debug-symbols
ac_add_options --disable-installer
ac_add_options --disable-static
ac_add_options --disable-tests
ac_add_options --disable-updater
ac_add_options --enable-application=suite
ac_add_options --enable-shared
ac_add_options --enable-system-ffi
ac_add_options --prefix=/usr
ac_add_options --with-pthreads
ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib
EOF

export CPLUS_INCLUDE_PATH=$XORG_PREFIX/include
export C_INCLUDE_PATH=$XORG_PREFIX/include

make -f client.mk 
make -C moz-build-dir/suite/installer

rm -rf    /usr/lib/seamonkey-2.24 
mkdir -pv -pv /usr/lib/seamonkey-2.24 

tar -xf moz-build-dir/mozilla/dist/seamonkey-2.24.en-US.linux-$(uname -m).tar.bz2 -C /usr/lib/seamonkey-2.24 --strip-components=1  

ln -sfv ../lib/seamonkey-2.24/seamonkey /usr/bin   

mkdir -pv -pv /usr/lib/mozilla/plugins                   
ln -sfv ../mozilla/plugins /usr/lib/seamonkey-2.24 

cp -v moz-build-dir/mozilla/dist/man/man1/seamonkey.1 /usr/share/man/man1

make -C moz-build-dir install

mkdir -pv -pv /usr/share/{applications,pixmaps}              

cat > /usr/share/applications/seamonkey.desktop << "EOF" 
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=SeaMonkey
Comment=The Mozilla Suite
Icon=seamonkey
Exec=seamonkey
Categories=Network;GTK;Application;Email;Browser;WebBrowser;News;
StartupNotify=true
Terminal=false
EOF

ln -sfv /usr/lib/seamonkey-2.24/chrome/icons/default/seamonkey.png /usr/share/pixmaps


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean

%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Xulrunner is a runtime environment for XUL applications, and forms the major part of the Mozilla codebase. In particular, it provides the Gecko engine together with pkgconfig files so that other applications can find and use it. 
Name:       xulrunner
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
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/firefox-23.0.1-system_cairo-1.patch
URL:        http://releases.mozilla.org/pub/mozilla.org/firefox/releases/23.0.1/source
%description
 Xulrunner is a runtime environment for XUL applications, and forms the major part of the Mozilla codebase. In particular, it provides the Gecko engine together with pkgconfig files so that other applications can find and use it. 
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
# GStreamer is necesary for H.264 video playback in HTML5 Video Player
#ac_add_options --enable-gstreamer
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
patch -Np1 -i %_sourcedir/firefox-23.0.1-system_cairo-1.patch
make -f client.mk %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/xulrunner-devel-23.0.1/sdk/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/xulrunner-23.0.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/xulrunner-devel-23.0.1/sdk/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins
make -C xulrunner-build-dir install  DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/mozilla/plugins 

rm -rf ${RPM_BUILD_ROOT}/usr/lib/xulrunner-23.0.1/plugins 

ln -sv ../mozilla/plugins ${RPM_BUILD_ROOT}/usr/lib/xulrunner-23.0.1 

for library in libmozalloc.so libmozjs.so libxul.so; do
    ln -sfv ../../../xulrunner-23.0.1/$library ${RPM_BUILD_ROOT}/usr/lib/xulrunner-devel-23.0.1/sdk/lib/$library

    ln -sfv xulrunner-23.0.1/$library ${RPM_BUILD_ROOT}/usr/lib/$library

done
ln -sfv ../xulrunner-devel-23.0.1/sdk/bin/run-mozilla.sh ${RPM_BUILD_ROOT}/usr/lib/xulrunner-23.0.1

ln -sfv ../xulrunner-devel-23.0.1/sdk/bin/xpcshell ${RPM_BUILD_ROOT}/usr/lib/xulrunner-23.0.1


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/xulrunner-devel-23.0.1/sdk/bin/xpcshell 
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
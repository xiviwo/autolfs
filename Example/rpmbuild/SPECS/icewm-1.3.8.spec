%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     IceWM is a window manager with the goals of speed, simplicity, and not getting in the user's way. 
Name:       icewm
Version:    1.3.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Requires:  gdk-pixbuf
Source0:    http://downloads.sourceforge.net/icewm/icewm-1.3.8.tar.gz
URL:        http://downloads.sourceforge.net/icewm
%description
 IceWM is a window manager with the goals of speed, simplicity, and not getting in the user's way. 
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
sed -i '/^LIBS/s/\(.*\)/\1 -lfontconfig/' src/Makefile.in &&
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/icewm
make install         && DESTDIR=${RPM_BUILD_ROOT} 

make install-docs    && DESTDIR=${RPM_BUILD_ROOT} 

make install-man     && DESTDIR=${RPM_BUILD_ROOT} 

make install-desktop DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo icewm-session > ~/.xinitrc

mkdir -pv ~/.icewm                                       &&

cp -v /usr/share/icewm/keys ~/.icewm/keys               &&

cp -v /usr/share/icewm/menu ~/.icewm/menu               &&

cp -v /usr/share/icewm/preferences ~/.icewm/preferences &&

cp -v /usr/share/icewm/toolbar ~/.icewm/toolbar         &&

cp -v /usr/share/icewm/winoptions ~/.icewm/winoptions

cat > ~/.icewm/menu << "EOF"

prog Urxvt xterm urxvt

prog GVolWheel /usr/share/pixmaps/gvolwheel/audio-volume-medium gvolwheel

separator

menufile General folder general

menufile Multimedia folder multimedia

menufile Tool_bar folder toolbar

EOF &&

>cat > ~/.icewm/general << "EOF"

prog Firefox firefox firefox

prog Epiphany /usr/share/icons/gnome/16x16/apps/web-browser epiphany

prog Midori /usr/share/icons/hicolor/24x24/apps/midori midori

separator

prog Gimp /usr/share/icons/hicolor/16x16/apps/gimp gimp

separator

prog Evince /usr/share/icons/hicolor/16x16/apps/evince evince

prog Epdfview /usr/share/epdfview/pixmaps/icon_epdfview-48 epdfview

EOF &&

>cat > ~/.icewm/multimedia << "EOF"

prog Audacious /usr/share/icons/hicolor/48x48/apps/audacious audacious

separator

prog Parole /usr/share/icons/hicolor/16x16/apps/parole parole

prog Totem /usr/share/icons/hicolor/16x16/apps/totem totem

prog Vlc /usr/share/icons/hicolor/16x16/apps/vlc vlc

prog Xine /usr/share/pixmaps/xine xine

EOF &&

cat > ~/.icewm/startup << "EOF"

rox -p Default &

EOF &&

chmod +x ~/.icewm/startup
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
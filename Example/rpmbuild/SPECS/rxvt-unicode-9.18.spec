%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     rxvt-unicode is a clone of the terminal emulator rxvt, an X Window System terminal emulator which includes support for XFT and Unicode. 
Name:       rxvt-unicode
Version:    9.18
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Requires:  pkg-config
Source0:    http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.18.tar.bz2
URL:        http://dist.schmorp.de/rxvt-unicode/Attic
%description
 rxvt-unicode is a clone of the terminal emulator rxvt, an X Window System terminal emulator which includes support for XFT and Unicode. 
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
./configure --prefix=/usr --enable-everything 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/X11/app-defaults
make install DESTDIR=${RPM_BUILD_ROOT} 

# Start the urxvtd daemon

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/X11/app-defaults/URxvt << "EOF"

URxvt*perl-ext: matcher

URxvt*urlLauncher: firefox

URxvt.background: black

URxvt.foreground: yellow

URxvt*font: xft:Monospace:pixelsize=12

EOF

urxvtd -q -f -o &
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
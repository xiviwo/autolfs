%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     xterm is a terminal emulator for the X Window System. 
Name:       xterm
Version:    297
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-applications
Source0:    ftp://invisible-island.net/xterm/xterm-297.tgz
URL:        ftp://invisible-island.net/xterm
%description
 xterm is a terminal emulator for the X Window System. 
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
sed -i '/v0/,+1s/new:/new:kb=^?:/' termcap 
echo -e '\tkbs=\\177,' >>terminfo 
TERMINFO=/usr/share/terminfo ./configure $XORG_CONFIG --with-app-defaults=/etc/X11/app-defaults 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/X11/app-defaults
make install  DESTDIR=${RPM_BUILD_ROOT} 

make install-ti DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/X11/app-defaults/XTerm << "EOF"

*VT100*locale: true

*VT100*faceName: Monospace

*VT100*faceSize: 10

*backarrowKeyIsErase: true

*ptyInitialErase: true

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
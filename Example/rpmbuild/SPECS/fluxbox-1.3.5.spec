%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Fluxbox package contains a window manager. 
Name:       fluxbox
Version:    1.3.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Source0:    http://downloads.sourceforge.net/fluxbox/fluxbox-1.3.5.tar.bz2
Source1:    ftp://ftp.jaist.ac.jp/pub//sourceforge/f/fl/fluxbox/fluxbox/1.3.5/fluxbox-1.3.5.tar.bz2
URL:        http://downloads.sourceforge.net/fluxbox
%description
 The Fluxbox package contains a window manager. 
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
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/fluxbox/styles
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/fluxbox
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/xsessions
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /usr/share/xsessions/fluxbox.desktop << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Fluxbox
Comment=This session logs you into Fluxbox
Exec=startfluxbox
Type=Application
EOF
fluxbox-generate_menu

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo startfluxbox > ~/.xinitrc

mkdir -pv ~/.fluxbox &&

cp -v /usr/share/fluxbox/init ~/.fluxbox/init &&

cp -v /usr/share/fluxbox/keys ~/.fluxbox/keys

cd ~/.fluxbox &&

cp -v /usr/share/fluxbox/menu ~/.fluxbox/menu

cp /usr/share/fluxbox/styles/<theme> ~/.fluxbox/theme &&

sed -i 's,\(session.styleFile:\).*,\1 ~/.fluxbox/theme,' ~/.fluxbox/init &&

echo "background.pixmap: </path/to/nice/image.xpm>" >> ~/.fluxbox/theme
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
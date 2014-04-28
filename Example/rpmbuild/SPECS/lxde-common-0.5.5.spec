%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The LXDE Common package provides a set of default configuration for LXDE. 
Name:       lxde-common
Version:    0.5.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  consolekit
Requires:  lxde-icon-theme
Requires:  lxpanel
Requires:  lxsession
Requires:  openbox
Requires:  pcmanfm
Requires:  desktop-file-utils
Requires:  hicolor-icon-theme
Requires:  shared-mime-info
Source0:    http://downloads.sourceforge.net/lxde/lxde-common-0.5.5.tar.gz
URL:        http://downloads.sourceforge.net/lxde
%description
 The LXDE Common package provides a set of default configuration for LXDE. 
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
sed -e "s:@prefix@/share/lxde/pcmanfm:@sysconfdir@/xdg/pcmanfm/LXDE:" -i startlxde.in &&
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/mime
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/icons/hicolor
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -Dm644 lxde-logout.desktop ${RPM_BUILD_ROOT}/usr/share/applications/lxde-logout.desktop

update-mime-database ${RPM_BUILD_ROOT}/usr/share/mime &&

startx

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
gtk-update-icon-cache -qf /usr/share/icons/hicolor &&

update-desktop-database -q

cat > ~/.xinitrc << "EOF"

ck-launch-session startlxde

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
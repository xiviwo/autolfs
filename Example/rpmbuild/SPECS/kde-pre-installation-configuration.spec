%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    kde-pre-installation-configuration
Name:       kde-pre-installation-configuration
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/kde/pre-install-config.html
%description
kde-pre-installation-configuration
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/dbus-1
mkdir -pv ${RPM_BUILD_ROOT}/etc/profile.d
mkdir -pv ${RPM_BUILD_ROOT}/opt
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/polkit-1
ln -svf $XORG_PREFIX ${RPM_BUILD_ROOT}/usr/X11R6

export KDE_PREFIX=${RPM_BUILD_ROOT}/usr
export KDE_PREFIX=${RPM_BUILD_ROOT}/opt/kde
cat > /etc/profile.d/kde.sh << 'EOF'
# Begin /etc/profile.d/kde.sh
KDE_PREFIX=/opt/kde
KDEDIR=$KDE_PREFIX
pathappend $KDE_PREFIX/bin             PATH
pathappend $KDE_PREFIX/lib/pkgconfig   PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share/pkgconfig PKG_CONFIG_PATH
pathappend $KDE_PREFIX/share           XDG_DATA_DIRS
pathappend /etc/kde/xdg                XDG_CONFIG_DIRS
export KDE_PREFIX KDEDIR
# End /etc/profile.d/kde.sh
EOF
install -d $KDE_PREFIX/share &&
ln -svf /usr/share/dbus-1 $KDE_PREFIX/share &&

ln -svf /usr/share/polkit-1 $KDE_PREFIX/share

mv ${RPM_BUILD_ROOT}/opt/kde{,-4.12.2} &&

ln -svf kde-4.12.2 ${RPM_BUILD_ROOT}/opt/kde


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/ld.so.conf << EOF

# Begin kde addition

/opt/kde/lib

# End kde addition

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
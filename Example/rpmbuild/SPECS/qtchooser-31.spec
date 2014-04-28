%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The qtchooser package contains a wrapper used to select between Qt binary versions. It is only needed if both Qt4 and Qt5 are installed for access via the /usr/bin directory. 
Name:       qtchooser
Version:    31
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://macieira.org/qtchooser/qtchooser-31-g980c64c.tar.gz
URL:        http://macieira.org/qtchooser
%description
 The qtchooser package contains a wrapper used to select between Qt binary versions. It is only needed if both Qt4 and Qt5 are installed for access via the /usr/bin directory. 
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
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/xdg/qtchooser
mkdir -pv ${RPM_BUILD_ROOT}/etc/xdg
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -m644 doc/qtchooser.1 ${RPM_BUILD_ROOT}/usr/share/man/man1

install -dm755 ${RPM_BUILD_ROOT}/etc/xdg/qtchooser 

cat > /etc/xdg/qtchooser/4.conf << "EOF"
/usr/lib/qt4/bin
/usr/lib
EOF
cat > /etc/xdg/qtchooser/5.conf << "EOF"
/usr/lib/qt5/bin
/usr/lib
EOF
ln -sfv 4.conf ${RPM_BUILD_ROOT}/etc/xdg/qtchooser/default.conf

ln -sfv 5.conf ${RPM_BUILD_ROOT}/etc/xdg/qtchooser/default.conf

export QT_SELECT=4
export QT_SELECT=5

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
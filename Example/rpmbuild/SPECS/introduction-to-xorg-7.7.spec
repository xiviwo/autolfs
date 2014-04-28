%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    introduction-to-xorg-7.7
Name:       introduction-to-xorg
Version:    7.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/x/xorg7.html
%description
introduction-to-xorg-7.7
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/X11
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/profile.d
mkdir -pv xc &&
cd xc
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=${RPM_BUILD_ROOT}/etc --localstatedir=${RPM_BUILD_ROOT}/var --disable-static"
cat > /etc/profile.d/xorg.sh << "EOF"
XORG_PREFIX="/opt"
XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
sed "s@/usr/X11R6@$XORG_PREFIX@g" -i ${RPM_BUILD_ROOT}/etc/man_db.conf

ln -svf $XORG_PREFIX/share/X11 ${RPM_BUILD_ROOT}/usr/share/X11

install -v -m755 -d $XORG_PREFIX &&
install -v -m755 -d $XORG_PREFIX/lib &&
ln -svf lib $XORG_PREFIX/lib64

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod 644 /etc/profile.d/xorg.sh

cat >> /etc/profile.d/xorg.sh << "EOF"

pathappend $XORG_PREFIX/bin             PATH

pathappend $XORG_PREFIX/lib/pkgconfig   PKG_CONFIG_PATH

pathappend $XORG_PREFIX/share/pkgconfig PKG_CONFIG_PATH

pathappend $XORG_PREFIX/lib             LIBRARY_PATH

pathappend $XORG_PREFIX/include         C_INCLUDE_PATH

pathappend $XORG_PREFIX/include         CPLUS_INCLUDE_PATH

ACLOCAL='aclocal -I $XORG_PREFIX/share/aclocal'

export PATH PKG_CONFIG_PATH ACLOCAL LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH

EOF

echo "$XORG_PREFIX/lib" >> /etc/ld.so.conf
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
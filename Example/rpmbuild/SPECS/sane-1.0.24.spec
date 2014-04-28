%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     SANE is short for Scanner Access Now Easy. Scanner access; however, is far from easy, since every vendor has their own protocols. The only known protocol that should bring some unity into this chaos is the TWAIN interface, but this is too imprecise to allow a stable scanning framework. Therefore, SANE comes with its own protocol, and the vendor drivers can't be used. 
Name:       sane
Version:    1.0.24
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://fossies.org/linux/misc//sane-backends-1.0.24.tar.gz
Source1:    http://alioth.debian.org/frs/download.php/file/1140/sane-frontends-1.0.14.tar.gz
Source2:    ftp://ftp2.sane-project.org/pub/sane/sane-frontends-1.0.14.tar.gz
URL:        http://fossies.org/linux/misc/
%description
 SANE is short for Scanner Access Now Easy. Scanner access; however, is far from easy, since every vendor has their own protocols. The only known protocol that should bring some unity into this chaos is the TWAIN interface, but this is too imprecise to allow a stable scanning framework. Therefore, SANE comes with its own protocol, and the vendor drivers can't be used. 
%pre
groupadd -g 70 scanner || :
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
su $(whoami)
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-docdir=/usr/share/doc/sane-backend-1.0.24 --with-group=scanner                             &&
make                                                         && %{?_smp_mflags} 

exit
sed -i -e 's/Jul 31 07:52:48/Oct  7 08:58:33/' -e 's/1.0.24git/1.0.24/' testsuite/tools/data/db.ref testsuite/tools/data/html-mfgs.ref testsuite/tools/data/usermap.ref testsuite/tools/data/html-backends-split.ref testsuite/tools/data/udev+acl.ref testsuite/tools/data/udev.ref

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/sane.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
mkdir -pv ${RPM_BUILD_ROOT}/etc/udev/rules.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/var/lock
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/gimp/2.0
mkdir -pv ${RPM_BUILD_ROOT}/usr/share
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/
make install                                         && DESTDIR=${RPM_BUILD_ROOT} 

install -m 644 -v tools/udev/libsane.rules ${RPM_BUILD_ROOT}/etc/udev/rules.d/65-scanner.rules &&

sed -i -e "/SANE_CAP_ALWAYS_SETTABLE/d" src/gtkglue.c &&
./configure --prefix=${RPM_BUILD_ROOT}/usr &&
make
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 doc/sane.png xscanimage-icon-48x48-2.png ${RPM_BUILD_ROOT}/usr/share/sane

ln -v -s ../../../../bin/xscanimage ${RPM_BUILD_ROOT}/usr/lib/gimp/2.0/plug-ins

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/{applications,pixmaps}               &&

cat > /usr/share/applications/xscanimage.desktop << "EOF" &&
[Desktop Entry]
Encoding=UTF-8
Name=XScanImage - Scanning
Comment=Acquire images from a scanner
Exec=xscanimage
Icon=xscanimage
Terminal=false
Type=Application
Categories=Application;Graphics
EOF
ln -svf  %_sourcedir/sane/xscanimage-icon-48x48-2.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/xscanimage.png


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chgrp -v scanner  /var/lock/sane

cat >> /etc/sane.d/net.conf << "EOF"

connect_timeout = 60

<server_ip>

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
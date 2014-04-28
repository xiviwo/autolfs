%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gimp package contains the GNU Image Manipulation Program which is useful for photo retouching, image composition and image authoring. 
Name:       gimp
Version:    2.8.6
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gegl
Requires:  gtk
Requires:  intltool
Requires:  pygtk
Source0:    http://artfiles.org/gimp.org/gimp/v2.8/gimp-2.8.6.tar.bz2
Source1:    ftp://ftp.gimp.org/pub/gimp/v2.8/gimp-2.8.6.tar.bz2
Source2:    ftp://gimp.org/pub/gimp/help/gimp-help-2.8.0.tar.bz2
Source3:    ftp://anduin.linuxfromscratch.org/other/gimp-help-2.8.0-build_fixes-1.patch.xz
URL:        http://artfiles.org/gimp.org/gimp/v2.8
%description
 The Gimp package contains the GNU Image Manipulation Program which is useful for photo retouching, image composition and image authoring. 
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
./configure --prefix=/usr --sysconfdir=/etc --without-gvfs 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/gimp/2.0
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gimp/2.0
make install DESTDIR=${RPM_BUILD_ROOT} 

ALL_LINGUAS="da de el en en_GB es fi fr hr it ja ko lt nl nn pl ru sl sv zh_CN" ./configure --prefix=${RPM_BUILD_ROOT}/usr 
xzcat ../gimp-help-2.8.0-build_fixes-1.patch.xz | patch -p1 
./autogen.sh --prefix=${RPM_BUILD_ROOT}/usr 
make
make install  DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R root:root /usr/share/gimp/2.0/help

gtk-update-icon-cache 

update-desktop-database

echo '(web-browser "<browser> %s")' >> /etc/gimp/2.0/gimprc
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
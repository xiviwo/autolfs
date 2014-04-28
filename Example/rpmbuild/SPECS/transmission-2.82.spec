%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Transmission is a cross-platform, open source BitTorrent client. This is useful for downloading large files (such as Linux ISOs) and reduces the need for the distributors to provide server bandwidth. 
Name:       transmission
Version:    2.82
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  curl
Requires:  intltool
Requires:  libevent
Requires:  openssl
Requires:  gtk
Requires:  qt
Source0:    http://download.transmissionbt.com/files/transmission-2.82.tar.xz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/transmission-2.82-qt4-1.patch
URL:        http://download.transmissionbt.com/files
%description
 Transmission is a cross-platform, open source BitTorrent client. This is useful for downloading large files (such as Linux ISOs) and reduces the need for the distributors to provide server bandwidth. 
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
patch -Np1 -i %_sourcedir/transmission-2.82-qt4-1.patch
./configure --prefix=/usr &&
make %{?_smp_mflags} 
pushd qt        &&
  qmake qtr.pro &&
make          && %{?_smp_mflags} 

popd

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
make install DESTDIR=${RPM_BUILD_ROOT} 

make INSTALL_ROOT=${RPM_BUILD_ROOT}/usr -C qt install && DESTDIR=${RPM_BUILD_ROOT} 

install -m644 qt/transmission-qt.desktop ${RPM_BUILD_ROOT}/usr/share/applications/transmission-qt.desktop &&

install -m644 qt/icons/transmission.png  ${RPM_BUILD_ROOT}/usr/share/pixmaps/transmission-qt.png


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
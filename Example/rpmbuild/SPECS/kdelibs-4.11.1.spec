%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package includes programs and libraries that are central to development and execution of KDE programs. 
Name:       kdelibs
Version:    4.11.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  phonon
Requires:  attica
Requires:  soprano
Requires:  strigi
Requires:  qca
Requires:  libdbusmenu-qt
Requires:  docbook-xml
Requires:  docbook-xsl
Requires:  shared-desktop-ontologies
Requires:  shared-mime-info
Requires:  polkit-qt
Requires:  libpng
Requires:  libjpeg-turbo
Requires:  giflib
Requires:  upower
Requires:  udisks
Source0:    http://download.kde.org/stable/4.11.1/src/kdelibs-4.11.1.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/4.11.1/src/kdelibs-4.11.1.tar.xz
URL:        http://download.kde.org/stable/4.11.1/src
%description
 This package includes programs and libraries that are central to development and execution of KDE programs. 
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
sed -i "s@{SYSCONF_INSTALL_DIR}/xdg/menus@& RENAME kde-applications.menu@" kded/CMakeLists.txt 
sed -i "s@applications.menu@kde-&@" kded/kbuildsycoca.cpp
mkdir -pv build 
cd    build 
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -DDOCBOOKXML_CURRENTDTD_DIR=/usr/share/xml/docbook/xml-dtd-4.5 .. 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build 


make install DESTDIR=${RPM_BUILD_ROOT} 


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
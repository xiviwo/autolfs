%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Kde-runtime contains runtime applications and libraries essential for KDE. 
Name:       kde-runtime
Version:    4.11.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  kdelibs
Requires:  libtirpc
Requires:  kactivities
Requires:  kdepimlibs
Requires:  alsa-lib
Requires:  libjpeg-turbo
Requires:  exiv2
Source0:    http://download.kde.org/stable/4.11.1/src/kde-runtime-4.11.1.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/4.11.1/src/kde-runtime-4.11.1.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/kde-runtime-4.11.1-rpc_fix-1.patch
URL:        http://download.kde.org/stable/4.11.1/src
%description
 Kde-runtime contains runtime applications and libraries essential for KDE. 
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
patch -Np1 -i %_sourcedir/kde-runtime-4.11.1-rpc_fix-1.patch 
mkdir -pv build 
cd    build 
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release .. 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build 


make install  DESTDIR=${RPM_BUILD_ROOT} 

ln -svf -v ../lib/kde4/libexec/kdesu $KDE_PREFIX/bin/kdesu

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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Gnash is the GNU Flash movie player and browser plugin. This is useful for watching YouTube videos or simple flash animations. 
Name:       gnash
Version:    0.8.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  agg
Requires:  boost
Requires:  curl
Requires:  gst-ffmpeg
Requires:  npapi-sdk
Requires:  giflib
Source0:    http://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2
Source1:    ftp://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/gnash-0.8.10-CVE-2012-1175-1.patch
URL:        http://ftp.gnu.org/pub/gnu/gnash/0.8.10
%description
 Gnash is the GNU Flash movie player and browser plugin. This is useful for watching YouTube videos or simple flash animations. 
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
patch -Np1 -i %_sourcedir/gnash-0.8.10-CVE-2012-1175-1.patch &&
sed -i '/^LIBS/s/\(.*\)/\1 -lboost_system/' gui/Makefile.in utilities/Makefile.in &&
sed -i "/DGifOpen/s:Data:&, NULL:" libbase/GnashImageGif.cpp &&
sed -i '/#include <csignal>/a\#include <unistd.h>' plugin/klash4/klash_part.cpp &&
./configure --prefix=/usr --sysconfdir=/etc --with-npapi-incl=/usr/include/npapi-sdk --enable-media=gst --with-npapi-plugindir=/usr/lib/mozilla/plugins --without-gconf &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install && DESTDIR=${RPM_BUILD_ROOT} 

make install-plugin DESTDIR=${RPM_BUILD_ROOT} 


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
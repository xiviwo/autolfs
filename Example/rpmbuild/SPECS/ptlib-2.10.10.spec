%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Ptlib (Portable Tools Library) package contains a class library that has its genesis many years ago as PWLib (portable Windows Library), a method to produce applications to run on various platforms. 
Name:       ptlib
Version:    2.10.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Requires:  expat
Requires:  openssl
Source0:    http://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/ptlib-2.10.10-bison_fixes-1.patch
URL:        http://ftp.gnome.org/pub/gnome/sources/ptlib/2.10
%description
 The Ptlib (Portable Tools Library) package contains a class library that has its genesis many years ago as PWLib (portable Windows Library), a method to produce applications to run on various platforms. 
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
patch -Np1 -i %_sourcedir/ptlib-2.10.10-bison_fixes-1.patch &&
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libpt.so.2.10.10
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
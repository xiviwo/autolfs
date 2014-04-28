%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libmusicbrainz package contains a library which allows you to access the data held on the MusicBrainz server. 
Name:       libmusicbrainz
Version:    5.0.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  neon
Source0:    https://github.com/downloads/metabrainz/libmusicbrainz/libmusicbrainz-5.0.1.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/libmusicbrainz-5.0.1-build_system-1.patch
URL:        https://github.com/downloads/metabrainz/libmusicbrainz
%description
 The libmusicbrainz package contains a library which allows you to access the data held on the MusicBrainz server. 
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
patch -Np1 -i %_sourcedir/libmusicbrainz-5.0.1-build_system-1.patch &&
mkdir -pv build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&


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
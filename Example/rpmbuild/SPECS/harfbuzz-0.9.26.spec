%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Harfbuzz package contains an OpenType text shaping engine. 
Name:       harfbuzz
Version:    0.9.26
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  icu
Requires:  freetype
Source0:    http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.26.tar.bz2
URL:        http://www.freedesktop.org/software/harfbuzz/release
%description
 The Harfbuzz package contains an OpenType text shaping engine. 
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
./configure --prefix=/usr --with-gobject &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


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
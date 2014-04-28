%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     JS is Mozilla's JavaScript engine written in C/C++. 
Name:       js
Version:    17.0.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libffi
Requires:  nspr
Requires:  python
Requires:  zip
Source0:    http://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz
Source1:    ftp://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz
URL:        http://ftp.mozilla.org/pub/mozilla.org/js
%description
 JS is Mozilla's JavaScript engine written in C/C++. 
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
cd js/src &&
./configure --prefix=/usr --enable-readline --enable-threadsafe --with-system-ffi --with-system-nspr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd js/src &&

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/pkgconfig
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/include/js-17.0/
make install && DESTDIR=${RPM_BUILD_ROOT} 

find ${RPM_BUILD_ROOT}/usr/include/js-17.0/ ${RPM_BUILD_ROOT}/usr/lib/libmozjs-17.0.a ${RPM_BUILD_ROOT}/usr/lib/pkgconfig/mozjs-17.0.pc -type f -exec chmod -v 644 {} \;


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
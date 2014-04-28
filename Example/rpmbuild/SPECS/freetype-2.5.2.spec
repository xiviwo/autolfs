%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The FreeType2 package contains a library which allows applications to properly render TrueType fonts. 
Name:       freetype
Version:    2.5.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  which
Requires:  libpng
Source0:    http://downloads.sourceforge.net/freetype/freetype-2.5.2.tar.bz2
Source1:    http://downloads.sourceforge.net/freetype/freetype-doc-2.5.2.tar.bz2
URL:        http://downloads.sourceforge.net/freetype
%description
 The FreeType2 package contains a library which allows applications to properly render TrueType fonts. 
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
tar -xf  %_sourcedir/freetype-doc-2.5.2.tar.bz2 --strip-components=2 -C docs
sed -i  -e "/AUX.*.gxvalid/s@^# @@" -e "/AUX.*.otvalid/s@^# @@" modules.cfg                        &&
sed -ri -e 's:.*(#.*SUBPIXEL.*) .*:\1:' include/config/ftoption.h          &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/freetype-2.5.2
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/freetype-2.5.2 &&

cp -v -R docs/*     ${RPM_BUILD_ROOT}/usr/share/doc/freetype-2.5.2


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
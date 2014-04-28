%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenSP package contains a C++ library for using SGML/XML files. This is useful for validating, parsing and manipulating SGML and XML documents. 
Name:       opensp
Version:    1.5.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  sgml-common
Source0:    http://downloads.sourceforge.net/openjade/OpenSP-1.5.2.tar.gz
URL:        http://downloads.sourceforge.net/openjade
%description
 The OpenSP package contains a C++ library for using SGML/XML files. This is useful for validating, parsing and manipulating SGML and XML documents. 
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
sed -i 's/32,/253,/' lib/Syntax.cxx &&
sed -i 's/LITLEN          240 /LITLEN          8092/' unicode/{gensyntax.pl,unicode.syn} &&
./configure --prefix=/usr --disable-static --disable-doc-build --enable-default-catalog=/etc/sgml/catalog --enable-http --enable-default-search-path=/usr/share/sgml &&
make pkgdatadir=/usr/share/sgml/OpenSP-1.5.2 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make pkgdatadir=${RPM_BUILD_ROOT}/usr/share/sgml/OpenSP-1.5.2 install && DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf onsgmls ${RPM_BUILD_ROOT}/usr/bin/nsgmls &&

ln -v -sf osgmlnorm ${RPM_BUILD_ROOT}/usr/bin/sgmlnorm &&

ln -v -sf ospam ${RPM_BUILD_ROOT}/usr/bin/spam &&

ln -v -sf ospcat ${RPM_BUILD_ROOT}/usr/bin/spcat &&

ln -v -sf ospent ${RPM_BUILD_ROOT}/usr/bin/spent &&

ln -v -sf osx ${RPM_BUILD_ROOT}/usr/bin/sx &&

ln -v -sf osx ${RPM_BUILD_ROOT}/usr/bin/sgml2xml &&

ln -v -sf libosp.so ${RPM_BUILD_ROOT}/usr/lib/libsp.so


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
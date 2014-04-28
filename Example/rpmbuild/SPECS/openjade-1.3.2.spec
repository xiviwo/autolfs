%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The OpenJade package contains a DSSSL engine. This is useful for SGML and XML transformations into RTF, TeX, SGML and XML. 
Name:       openjade
Version:    1.3.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  opensp
Source0:    http://downloads.sourceforge.net/openjade/openjade-1.3.2.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/openjade-1.3.2-gcc_4.6-1.patch
URL:        http://downloads.sourceforge.net/openjade
%description
 The OpenJade package contains a DSSSL engine. This is useful for SGML and XML transformations into RTF, TeX, SGML and XML. 
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
patch -Np1 -i %_sourcedir/openjade-1.3.2-gcc_4.6-1.patch
sed -i -e '/getopts/{N;s#&G#g#;s#do .getopts.pl.;##;}' -e '/use POSIX/ause Getopt::Std;' msggen.pl
./configure --prefix=/usr --mandir=/usr/share/man --enable-http --disable-static --enable-default-catalog=/etc/sgml/catalog --enable-default-search-path=/usr/share/sgml --datadir=/usr/share/sgml/openjade-1.3.2   &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/openjade-1.3.2
mkdir -pv ${RPM_BUILD_ROOT}/etc/sgml
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install                                                   && DESTDIR=${RPM_BUILD_ROOT} 

make install-man                                               && DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf openjade ${RPM_BUILD_ROOT}/usr/bin/jade                               &&

ln -v -sf libogrove.so ${RPM_BUILD_ROOT}/usr/lib/libgrove.so                    &&

ln -v -sf libospgrove.so ${RPM_BUILD_ROOT}/usr/lib/libspgrove.so                &&

ln -v -sf libostyle.so ${RPM_BUILD_ROOT}/usr/lib/libstyle.so                    &&

install -v -m644 dsssl/catalog ${RPM_BUILD_ROOT}/usr/share/sgml/openjade-1.3.2/ &&

install -v -m644 dsssl/*.{dtd,dsl,sgm} ${RPM_BUILD_ROOT}/usr/share/sgml/openjade-1.3.2                             &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/openjade-1.3.2.cat ${RPM_BUILD_ROOT}/usr/share/sgml/openjade-1.3.2/catalog                     &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook.cat ${RPM_BUILD_ROOT}/etc/sgml/openjade-1.3.2.cat


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo "SYSTEM \"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd\" \"/usr/share/xml/docbook/xml-dtd-4.5/docbookx.dtd\"" >> /usr/share/sgml/openjade-1.3.2/catalog
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
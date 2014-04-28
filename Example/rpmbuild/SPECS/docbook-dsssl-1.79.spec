%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The DocBook DSSSL Stylesheets package contains DSSSL stylesheets. These are used by OpenJade or other tools to transform SGML and XML DocBook files. 
Name:       docbook-dsssl
Version:    1.79
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  sgml-common
Requires:  docbook
Requires:  docbook
Requires:  opensp
Requires:  openjade
Source0:    http://downloads.sourceforge.net/docbook/docbook-dsssl-1.79.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/docbook-dsssl-1.79.tar.bz2
Source2:    http://downloads.sourceforge.net/docbook/docbook-dsssl-doc-1.79.tar.bz2
URL:        http://downloads.sourceforge.net/docbook
%description
 The DocBook DSSSL Stylesheets package contains DSSSL stylesheets. These are used by OpenJade or other tools to transform SGML and XML DocBook files. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/html
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/common
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79
mkdir -pv ${RPM_BUILD_ROOT}/etc/sgml
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/print
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
tar -xf  %_sourcedir/docbook-dsssl-doc-1.79.tar.bz2 --strip-components=1
install -v -m755 bin/collateindex.pl ${RPM_BUILD_ROOT}/usr/bin                      &&

install -v -m644 bin/collateindex.pl.1 ${RPM_BUILD_ROOT}/usr/share/man/man1         &&

install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79 &&

cp -v -R * ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79          &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/dsssl-docbook-stylesheets.cat ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/catalog         &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/dsssl-docbook-stylesheets.cat ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/common/catalog  &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook.cat ${RPM_BUILD_ROOT}/etc/sgml/dsssl-docbook-stylesheets.cat

cd ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/doc/testdata

openjade -t rtf -d jtest.dsl jtest.sgm
onsgmls -sv test.sgm
openjade -t rtf -d ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/print/docbook.dsl test.sgm

openjade -t sgml -d ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/dsssl-stylesheets-1.79/html/docbook.dsl test.sgm

rm jtest.rtf test.rtf c1.htm

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
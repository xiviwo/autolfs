%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The DocBook XSL Stylesheets package contains XSL stylesheets. These are useful for performing transformations on XML DocBook files. 
Name:       docbook-xsl
Version:    1.78.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxml2
Source0:    http://downloads.sourceforge.net/docbook/docbook-xsl-1.78.1.tar.bz2
Source1:    http://downloads.sourceforge.net/docbook/docbook-xsl-doc-1.78.1.tar.bz2
URL:        http://downloads.sourceforge.net/docbook
%description
 The DocBook XSL Stylesheets package contains XSL stylesheets. These are useful for performing transformations on XML DocBook files. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xsl-stylesheets-1.78.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/docbook-xsl-1.78.1
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/xml
tar -xf  %_sourcedir/docbook-xsl-doc-1.78.1.tar.bz2 --strip-components=1
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xsl-stylesheets-1.78.1 &&

cp -v -R VERSION common eclipse epub extensions fo highlighting html htmlhelp images javahelp lib manpages params profiling roundtrip slides template tests tools webhelp website xhtml xhtml-1_1 ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xsl-stylesheets-1.78.1 &&

ln -svf VERSION ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xsl-stylesheets-1.78.1/VERSION.xsl &&

install -v -m644 -D README ${RPM_BUILD_ROOT}/usr/share/doc/docbook-xsl-1.78.1/README.txt &&

install -v -m644    RELEASE-NOTES* NEWS* ${RPM_BUILD_ROOT}/usr/share/doc/docbook-xsl-1.78.1

cp -v -R doc/* ${RPM_BUILD_ROOT}/usr/share/doc/docbook-xsl-1.78.1

if [ ! -d ${RPM_BUILD_ROOT}/etc/xml ]; then install -v -m755 -d ${RPM_BUILD_ROOT}/etc/xml; fi &&

if [ ! -f ${RPM_BUILD_ROOT}/etc/xml/catalog ]; then

    xmlcatalog --noout --create ${RPM_BUILD_ROOT}/etc/xml/catalog

fi &&
xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/1.78.1" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/1.78.1" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/current" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/current" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" ${RPM_BUILD_ROOT}/etc/xml/catalog

xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/<version>" "/usr/share/xml/docbook/xsl-stylesheets-<version>" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/<version>" "/usr/share/xml/docbook/xsl-stylesheets-<version>" ${RPM_BUILD_ROOT}/etc/xml/catalog


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
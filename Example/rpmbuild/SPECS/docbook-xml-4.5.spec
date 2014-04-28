%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The DocBook XML DTD-4.5 package contains document type definitions for verification of XML data files against the DocBook rule set. These are useful for structuring books and software documentation to a standard allowing you to utilize transformations already written for that standard. 
Name:       docbook-xml
Version:    4.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxml2
Requires:  unzip
Source0:    http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/docbook-xml-4.5.zip
URL:        http://www.docbook.org/xml/4.5
%description
 The DocBook XML DTD-4.5 package contains document type definitions for verification of XML data files against the DocBook rule set. These are useful for structuring books and software documentation to a standard allowing you to utilize transformations already written for that standard. 
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

mkdir -pv ${RPM_BUILD_ROOT}/etc/xml
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xml-dtd-4.5
install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xml-dtd-4.5 &&

install -v -d -m755 ${RPM_BUILD_ROOT}/etc/xml &&

cp -v -af docbook.cat *.dtd ent/ *.mod ${RPM_BUILD_ROOT}/usr/share/xml/docbook/xml-dtd-4.5

if [ ! -e ${RPM_BUILD_ROOT}/etc/xml/docbook ]; then

    xmlcatalog --noout --create ${RPM_BUILD_ROOT}/etc/xml/docbook

fi &&
xmlcatalog --noout --add "public" "-//OASIS//DTD DocBook XML V4.5//EN" "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//DTD XML Exchange Table Model 19990315//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "public" "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "rewriteSystem" "http://www.oasis-open.org/docbook/xml/4.5" "file:///usr/share/xml/docbook/xml-dtd-4.5" ${RPM_BUILD_ROOT}/etc/xml/docbook &&

xmlcatalog --noout --add "rewriteURI" "http://www.oasis-open.org/docbook/xml/4.5" "file:///usr/share/xml/docbook/xml-dtd-4.5" ${RPM_BUILD_ROOT}/etc/xml/docbook

if [ ! -e ${RPM_BUILD_ROOT}/etc/xml/catalog ]; then

    xmlcatalog --noout --create ${RPM_BUILD_ROOT}/etc/xml/catalog

fi &&
xmlcatalog --noout --add "delegatePublic" "-//OASIS//ENTITIES DocBook XML" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "delegatePublic" "-//OASIS//DTD DocBook XML" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "delegateSystem" "http://www.oasis-open.org/docbook/" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog &&

xmlcatalog --noout --add "delegateURI" "http://www.oasis-open.org/docbook/" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog

for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
  xmlcatalog --noout --add "public" "-//OASIS//DTD DocBook XML V$DTDVERSION//EN" "http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd" ${RPM_BUILD_ROOT}/etc/xml/docbook

  xmlcatalog --noout --add "rewriteSystem" "http://www.oasis-open.org/docbook/xml/$DTDVERSION" "file:///usr/share/xml/docbook/xml-dtd-4.5" ${RPM_BUILD_ROOT}/etc/xml/docbook

  xmlcatalog --noout --add "rewriteURI" "http://www.oasis-open.org/docbook/xml/$DTDVERSION" "file:///usr/share/xml/docbook/xml-dtd-4.5" ${RPM_BUILD_ROOT}/etc/xml/docbook

  xmlcatalog --noout --add "delegateSystem" "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog

  xmlcatalog --noout --add "delegateURI" "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" "file:///etc/xml/docbook" ${RPM_BUILD_ROOT}/etc/xml/catalog

done

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R root:root . &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
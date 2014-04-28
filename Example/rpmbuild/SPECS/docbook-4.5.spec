%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The DocBook SGML DTD package contains document type definitions for verification of SGML data files against the DocBook rule set. These are useful for structuring books and software documentation to a standard allowing you to utilize transformations already written for that standard. 
Name:       docbook
Version:    4.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  sgml-common
Requires:  unzip
Source0:    http://www.docbook.org/sgml/4.5/docbook-4.5.zip
URL:        http://www.docbook.org/sgml/4.5
%description
 The DocBook SGML DTD package contains document type definitions for verification of SGML data files against the DocBook rule set. These are useful for structuring books and software documentation to a standard allowing you to utilize transformations already written for that standard. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook
mkdir -pv ${RPM_BUILD_ROOT}/etc/sgml
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/sgml-dtd-4.5
sed -i -e '/ISO 8879/d' -e '/gml/d' docbook.cat
install -v -d ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/sgml-dtd-4.5 &&

install -v docbook.cat ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/sgml-dtd-4.5/catalog &&

cp -v -af *.dtd *.mod *.dcl ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/sgml-dtd-4.5 &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook-dtd-4.5.cat ${RPM_BUILD_ROOT}/usr/share/sgml/docbook/sgml-dtd-4.5/catalog &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook-dtd-4.5.cat ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook.cat


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -R root:root . &&

cat >> /usr/share/sgml/docbook/sgml-dtd-4.5/catalog << "EOF"

  -- Begin Single Major Version catalog changes --

PUBLIC "-//OASIS//DTD DocBook V4.4//EN" "docbook.dtd"

PUBLIC "-//OASIS//DTD DocBook V4.3//EN" "docbook.dtd"

PUBLIC "-//OASIS//DTD DocBook V4.2//EN" "docbook.dtd"

PUBLIC "-//OASIS//DTD DocBook V4.1//EN" "docbook.dtd"

PUBLIC "-//OASIS//DTD DocBook V4.0//EN" "docbook.dtd"

  -- End Single Major Version catalog changes --

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
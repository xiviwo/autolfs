%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The SGML Common package contains install-catalog. This is useful for creating and maintaining centralized SGML catalogs. 
Name:       sgml-common
Version:    0.6.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/sgml-common-0.6.3.tgz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/sgml-common-0.6.3-manpage-1.patch
URL:        ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES
%description
 The SGML Common package contains install-catalog. This is useful for creating and maintaining centralized SGML catalogs. 
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
patch -Np1 -i %_sourcedir/sgml-common-0.6.3-manpage-1.patch &&
autoreconf -f -i
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/sgml
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sgml/sgml-iso-entities-8879.1986
make docdir=${RPM_BUILD_ROOT}/usr/share/doc install && DESTDIR=${RPM_BUILD_ROOT} 

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-ent.cat ${RPM_BUILD_ROOT}/usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&

install-catalog --add ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook.cat ${RPM_BUILD_ROOT}/etc/sgml/sgml-ent.cat

install-catalog --remove ${RPM_BUILD_ROOT}/etc/sgml/sgml-ent.cat ${RPM_BUILD_ROOT}/usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&

install-catalog --remove ${RPM_BUILD_ROOT}/etc/sgml/sgml-docbook.cat ${RPM_BUILD_ROOT}/etc/sgml/sgml-ent.cat


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
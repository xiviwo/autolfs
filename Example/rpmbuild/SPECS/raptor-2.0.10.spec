%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Raptor is a C library that provides a set of parsers and serializers that generate Resource Description Framework (RDF) triples. 
Name:       raptor
Version:    2.0.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  curl
Requires:  libxslt
Source0:    http://download.librdf.org/source/raptor2-2.0.10.tar.gz
URL:        http://download.librdf.org/source
%description
 Raptor is a C library that provides a set of parsers and serializers that generate Resource Description Framework (RDF) triples. 
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
./configure --prefix=/usr --disable-static 
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
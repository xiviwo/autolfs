%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Redland is a set of free software C libraries that provide support for the Resource Description Framework (RDF). It is required by Soprano to build Nepomuk. 
Name:       redland
Version:    1.0.17
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  rasqal
Source0:    http://download.librdf.org/source/redland-1.0.17.tar.gz
URL:        http://download.librdf.org/source
%description
 Redland is a set of free software C libraries that provide support for the Resource Description Framework (RDF). It is required by Soprano to build Nepomuk. 
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
./configure --prefix=/usr --disable-static &&
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
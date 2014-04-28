%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libxml2 package contains libraries and utilities used for parsing XML files. 
Name:       libxml2
Version:    2.9.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Source0:    http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz
Source1:    ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz
Source2:    http://www.w3.org/XML/Test/xmlts20130923.tar.gz
URL:        http://xmlsoft.org/sources
%description
 The libxml2 package contains libraries and utilities used for parsing XML files. 
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
tar xf  %_sourcedir/xmlts20130923.tar.gz
./configure --prefix=/usr --disable-static --with-history &&
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
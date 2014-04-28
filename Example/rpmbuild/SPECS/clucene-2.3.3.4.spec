%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     CLucene is a C++ version of Lucene, a high performance text search engine. 
Name:       clucene
Version:    2.3.3.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  boost
Source0:    http://downloads.sourceforge.net/clucene/clucene-core-2.3.3.4.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/clucene-2.3.3.4-contribs_lib-1.patch
URL:        http://downloads.sourceforge.net/clucene
%description
 CLucene is a C++ version of Lucene, a high performance text search engine. 
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
patch -Np1 -i %_sourcedir/clucene-2.3.3.4-contribs_lib-1.patch &&
mkdir -pv build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_CONTRIBS_LIB=ON .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build &&


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
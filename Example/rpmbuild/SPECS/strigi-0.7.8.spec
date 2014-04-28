%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Strigi is a program for fast indexing and searching of personal data. It can gather and index information from files in the filesystem even if they are hidden in emails or archives. 
Name:       strigi
Version:    0.7.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  expat
Requires:  d-bus
Requires:  qt
Source0:    http://www.vandenoever.info/software/strigi/strigi-0.7.8.tar.bz2
URL:        http://www.vandenoever.info/software/strigi
%description
 Strigi is a program for fast indexing and searching of personal data. It can gather and index information from files in the filesystem even if they are hidden in emails or archives. 
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
sed -i "s/BufferedStream :/STREAMS_EXPORT &/" libstreams/include/strigi/bufferedstream.h &&
mkdir -pv build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DENABLE_CLUCENE=OFF -DENABLE_CLUCENE_NG=OFF .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&


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
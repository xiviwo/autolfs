%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Grantlee is a set of Free Software libraries written using the Qt framework. Currently two libraries are shipped with Grantlee: Grantlee Templates and Grantlee TextDocument. The goal of Grantlee Templates is to make it easier for application developers to separate the structure of documents from the data they contain, opening the door for theming. 
Name:       grantlee
Version:    0.3.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  qt
Source0:    http://downloads.grantlee.org/grantlee-0.3.0.tar.gz
URL:        http://downloads.grantlee.org
%description
 Grantlee is a set of Free Software libraries written using the Qt framework. Currently two libraries are shipped with Grantlee: Grantlee Templates and Grantlee TextDocument. The goal of Grantlee Templates is to make it easier for application developers to separate the structure of documents from the data they contain, opening the door for theming. 
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
mkdir -pv build 
cd    build 
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX ..

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build 


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
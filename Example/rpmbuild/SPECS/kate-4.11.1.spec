%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package provides two texteditors: Kate and KWrite. Kate is a powerful programmer's text editor with syntax highlighting for many programming and scripting languages. KWrite is the lightweight cousin of Kate. 
Name:       kate
Version:    4.11.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  kdelibs
Requires:  kactivities
Source0:    http://download.kde.org/stable/4.11.1/src/kate-4.11.1.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/4.11.1/src/kate-4.11.1.tar.xz
URL:        http://download.kde.org/stable/4.11.1/src
%description
 This package provides two texteditors: Kate and KWrite. Kate is a powerful programmer's text editor with syntax highlighting for many programming and scripting languages. KWrite is the lightweight cousin of Kate. 
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
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_BUILD_TYPE=Release -DINSTALL_PYTHON_FILES_IN_PYTHON_PREFIX=TRUE .. 
make %{?_smp_mflags} 

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
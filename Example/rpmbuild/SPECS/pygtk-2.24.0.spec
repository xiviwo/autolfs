%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Python module packages add useful objects to the Python language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page is meant to follow from top to bottom to handle optional dependencies in each module. 
Name:       pygtk
Version:    2.24.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  pygobject
Requires:  atk
Requires:  pango
Requires:  py2cairo
Requires:  pango
Requires:  py2cairo
Requires:  gtk
Requires:  py2cairo
Requires:  libglade
Source0:    http://ftp.gnome.org/pub/gnome/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2
URL:        http://ftp.gnome.org/pub/gnome/sources/pygtk/2.24
%description
 The Python module packages add useful objects to the Python language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page is meant to follow from top to bottom to handle optional dependencies in each module. 
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
./configure --prefix=/usr &&
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
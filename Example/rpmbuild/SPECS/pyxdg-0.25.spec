%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Python module packages add useful objects to the Python language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page is meant to follow from top to bottom to handle optional dependencies in each module. 
Name:       pyxdg
Version:    0.25
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Requires:  python
Source0:    http://people.freedesktop.org/~takluyver/pyxdg-0.25.tar.gz
URL:        http://people.freedesktop.org/~takluyver
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


python setup.py install --optimize=1
python3 setup.py install --optimize=1

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
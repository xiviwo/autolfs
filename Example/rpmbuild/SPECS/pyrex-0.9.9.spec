%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Python module packages add useful objects to the Python language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page is meant to follow from top to bottom to handle optional dependencies in each module. 
Name:       pyrex
Version:    0.9.9
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Source0:    http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/Pyrex-0.9.9.tar.gz
URL:        http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex
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


python setup.py install

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
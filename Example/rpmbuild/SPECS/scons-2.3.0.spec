%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     SCons is a tool for building software (and other files) implemented in Python. 
Name:       scons
Version:    2.3.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  python
Source0:    http://downloads.sourceforge.net/scons/scons-2.3.0.tar.gz
URL:        http://downloads.sourceforge.net/scons
%description
 SCons is a tool for building software (and other files) implemented in Python. 
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


python setup.py install --prefix=${RPM_BUILD_ROOT}/usr --standard-lib --optimize=1 --install-data=${RPM_BUILD_ROOT}/usr/share

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
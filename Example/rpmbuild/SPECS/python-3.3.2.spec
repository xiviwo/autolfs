%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Python 3 package contains the Python development environment. This is useful for object-oriented programming, writing scripts, prototyping large programs or developing entire applications. 
Name:       python
Version:    3.3.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  libffi
Requires:  pkg-config
Source0:    http://www.python.org/ftp/python/3.3.2/Python-3.3.2.tar.xz
Source1:    http://docs.python.org/ftp/python/doc/3.3.2/python-3.3.2-docs-html.tar.bz2
URL:        http://www.python.org/ftp/python/3.3.2
%description
 The Python 3 package contains the Python development environment. This is useful for object-oriented programming, writing scripts, prototyping large programs or developing entire applications. 
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
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install  DESTDIR=${RPM_BUILD_ROOT} 

export PYTHONDOCS=${RPM_BUILD_ROOT}/usr/share/doc/python-3.3.2/html

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libpython3.3m.so 

chmod -v 755 /usr/lib/libpython3.so
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
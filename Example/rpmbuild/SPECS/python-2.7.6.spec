%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Python 2 package contains the Python development environment. It is useful for object-oriented programming, writing scripts, prototyping large programs or developing entire applications. This version is for backward compatibility with other dependent packages. 
Name:       python
Version:    2.7.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  libffi
Source0:    http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
Source1:    http://docs.python.org/ftp/python/doc/2.7.6/python-2.7.6-docs-html.tar.bz2
URL:        http://www.python.org/ftp/python/2.7.6
%description
 The Python 2 package contains the Python development environment. It is useful for object-oriented programming, writing scripts, prototyping large programs or developing entire applications. This version is for backward compatibility with other dependent packages. 
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
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --enable-unicode=ucs4 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755 ${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6 &&

tar --strip-components=1 -C ${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6 --no-same-owner -xvf  %_sourcedir/python-2.7.6-docs-html.tar.bz2      &&

find ${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6 -type d -exec chmod 0755 {} \; &&

find ${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6 -type f -exec chmod 0644 {} \;

export PYTHONDOCS=${RPM_BUILD_ROOT}/usr/share/doc/python-2.7.6

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libpython2.7.so.1.0
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
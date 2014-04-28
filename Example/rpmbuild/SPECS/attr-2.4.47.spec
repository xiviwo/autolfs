%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The attr package contains utilities to administer the extended attributes on filesystem objects. 
Name:       attr
Version:    2.4.47
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://download.savannah.gnu.org/releases/attr/attr-2.4.47.src.tar.gz
URL:        http://download.savannah.gnu.org/releases/attr
%description
 The attr package contains utilities to administer the extended attributes on filesystem objects. 
%pre
INSTALL_USER=root INSTALL_GROUP=root ./configure --prefix=/usr --disable-static &&
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
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install install-dev install-lib && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libattr.so.* ${RPM_BUILD_ROOT}/lib &&

ln -sfv ../../lib/libattr.so.1 ${RPM_BUILD_ROOT}/usr/lib/libattr.so


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libattr.so &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
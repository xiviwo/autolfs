%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The acl package contains utilities to administer Access Control Lists, which are used to define more fine-grained discretionary access rights for files and directories. 
Name:       acl
Version:    2.2.52
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  attr
Source0:    http://download.savannah.gnu.org/releases/acl/acl-2.2.52.src.tar.gz
URL:        http://download.savannah.gnu.org/releases/acl
%description
 The acl package contains utilities to administer Access Control Lists, which are used to define more fine-grained discretionary access rights for files and directories. 
%pre
INSTALL_USER=root INSTALL_GROUP=root ./configure --prefix=/usr --libexecdir=/usr/lib --disable-static &&
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
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/acl-2.2.52
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install install-dev install-lib             && DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libacl.so.* ${RPM_BUILD_ROOT}/lib                  &&

ln -sfv ../../lib/libacl.so.1 ${RPM_BUILD_ROOT}/usr/lib/libacl.so &&

install -v -m644 doc/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/acl-2.2.52


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libacl.so                  &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
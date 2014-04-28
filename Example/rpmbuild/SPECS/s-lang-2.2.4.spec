%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     S-Lang is an interpreted language that may be embedded into an application to make the application extensible. It provides facilities required by interactive applications such as display/screen management, keyboard input and keymaps. 
Name:       s-lang
Version:    2.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://space.mit.edu/pub/davis/slang/v2.2/slang-2.2.4.tar.bz2
URL:        ftp://space.mit.edu/pub/davis/slang/v2.2
%description
 S-Lang is an interpreted language that may be embedded into an application to make the application extensible. It provides facilities required by interactive applications such as display/screen management, keyboard input and keymaps. 
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
./configure --prefix=/usr --sysconfdir=/etc --with-readline=gnu &&
make -j1 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/slang/v2/modules
make install_doc_dir=${RPM_BUILD_ROOT}/usr/share/doc/slang-2.2.4 SLSH_DOC_DIR=${RPM_BUILD_ROOT}/usr/share/doc/slang-2.2.4/slsh install-all && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libslang.so.2.2.4 /usr/lib/slang/v2/modules/*.so
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
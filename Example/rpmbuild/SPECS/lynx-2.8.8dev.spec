%define dist BLFS
Summary:     Lynx is a text based web browser. 
Name:       lynx
Version:    2.8.8dev
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://lynx.isc.org/current/lynx2.8.8dev.16.tar.bz2
Source1:    ftp://lynx.isc.org/current/lynx2.8.8dev.16.tar.bz2
URL:        http://lynx.isc.org/current
%description
 Lynx is a text based web browser. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}
./configure --prefix=/usr          \
            --sysconfdir=/etc/lynx \
            --datadir=/usr/share/doc/lynx-2.8.8dev.16 \
            --with-zlib            \
            --with-bzlib           \
            --with-screen=ncursesw \
            --enable-locale-charset &&
make %{?_smp_mflags} 

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/etc/lynx
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc/lynx-2.8.8dev.16
make install-full DESTDIR=$RPM_BUILD_ROOT &&
chgrp -v -R root ${RPM_BUILD_ROOT}/usr/share/doc/lynx-2.8.8dev.16/lynx_doc
echo "#define USE_OPENSSL_INCL 1" >> lynx_cfg.h
sed -i 's/#\(LOCALE_CHARSET\):FALSE/\1:TRUE/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg
sed -i 's/#\(DEFAULT_EDITOR\):/\1:vi/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg
sed -i 's/#\(PERSISTENT_COOKIES\):FALSE/\1:TRUE/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
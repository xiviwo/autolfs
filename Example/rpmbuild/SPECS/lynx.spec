%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Lynx is a text based web browser. 
Name:       lynx
Version:    1.0
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
./configure --prefix=/usr --sysconfdir=/etc/lynx --datadir=/usr/share/doc/lynx-2.8.8dev.16 --with-zlib --with-bzlib --with-screen=ncursesw --enable-locale-charset 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/lynx
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/lynx-2.8.8dev.16
make install-full  DESTDIR=${RPM_BUILD_ROOT} 

sed -i 's/#\(LOCALE_CHARSET\):FALSE/\1:TRUE/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg

sed -i 's/#\(DEFAULT_EDITOR\):/\1:vi/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg

sed -i 's/#\(PERSISTENT_COOKIES\):FALSE/\1:TRUE/' ${RPM_BUILD_ROOT}/etc/lynx/lynx.cfg


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chgrp -v -R root /usr/share/doc/lynx-2.8.8dev.16/lynx_doc

echo "#define USE_OPENSSL_INCL 1" >> lynx_cfg.h
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
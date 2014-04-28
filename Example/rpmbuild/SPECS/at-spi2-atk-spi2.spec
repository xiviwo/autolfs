%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The At-Spi2 Atk package contains a library that bridges ATK to At-Spi2 D-Bus service. 
Name:       at-spi2-atk
Version:    spi2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  at-spi2-core-spi2
Requires:  atk
Source0:    http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.10/at-spi2-atk-2.10.2.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.10/at-spi2-atk-2.10.2.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.10
%description
 The At-Spi2 Atk package contains a library that bridges ATK to At-Spi2 D-Bus service. 
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
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/glib-2.0/schemas
make install DESTDIR=${RPM_BUILD_ROOT} 

glib-compile-schemas ${RPM_BUILD_ROOT}/usr/share/glib-2.0/schemas


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
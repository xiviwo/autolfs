%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Babl package is a dynamic, any to any, pixel format translation library. 
Name:       babl
Version:    0.1.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.gimp.org/pub/babl/0.1/babl-0.1.10.tar.bz2
URL:        ftp://ftp.gimp.org/pub/babl/0.1
%description
 The Babl package is a dynamic, any to any, pixel format translation library. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/babl
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/babl/graphics
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/babl/graphics &&

install -v -m644 docs/*.{css,html} ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/babl &&

install -v -m644 docs/graphics/*.{html,png,svg} ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/babl/graphics


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package provides the GEneric Graphics Library, which is a graph based image processing format. 
Name:       gegl
Version:    0.2.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  babl
Source0:    ftp://ftp.gimp.org/pub/gegl/0.2/gegl-0.2.0.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/gegl-0.2.0-ffmpeg2-1.patch
URL:        ftp://ftp.gimp.org/pub/gegl/0.2
%description
 This package provides the GEneric Graphics Library, which is a graph based image processing format. 
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
patch -Np1 -i %_sourcedir/gegl-0.2.0-ffmpeg2-1.patch &&
./configure --prefix=/usr &&
LC_ALL=en_US make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/gegl/images
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/gegl
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 docs/*.{css,html} ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/gegl &&

install -d -v -m755 ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/gegl/images &&

install -v -m644 docs/images/* ${RPM_BUILD_ROOT}/usr/share/gtk-doc/html/gegl/images


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
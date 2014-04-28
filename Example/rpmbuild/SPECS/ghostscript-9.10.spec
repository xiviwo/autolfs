%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Ghostscript is a versatile processor for PostScript data with the ability to render PostScript to different targets. It used to be part of the cups printing stack, but is no longer used for that. 
Name:       ghostscript
Version:    9.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  freetype
Requires:  libjpeg-turbo
Requires:  libpng
Requires:  libtiff
Requires:  little-cms
Source0:    http://downloads.ghostscript.com/public/ghostscript-9.10.tar.bz2
Source1:    http://downloads.sourceforge.net/gs-fonts/ghostscript-fonts-std-8.11.tar.gz
Source2:    http://downloads.sourceforge.net/gs-fonts/gnu-gs-fonts-other-6.0.tar.gz
URL:        http://downloads.ghostscript.com/public
%description
 Ghostscript is a versatile processor for PostScript data with the ability to render PostScript to different targets. It used to be part of the cups printing stack, but is no longer used for that. 
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
rm -rf expat freetype lcms2 jpeg libpng
rm -rf zlib &&
./configure --prefix=/usr --disable-compile-inits --enable-dynamic --with-system-libtiff &&
make %{?_smp_mflags} 
make so %{?_smp_mflags} 

bin/gs -Ilib -IResource/Init -dBATCH examples/tiger.eps

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share
mkdir -pv ${RPM_BUILD_ROOT}/usr/include
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install DESTDIR=${RPM_BUILD_ROOT} 

make soinstall && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 base/*.h ${RPM_BUILD_ROOT}/usr/include/ghostscript &&

ln -v -s ghostscript ${RPM_BUILD_ROOT}/usr/include/ps

ln -sfv ../ghostscript/9.10/doc ${RPM_BUILD_ROOT}/usr/share/doc/ghostscript-9.10

tar -xvf  %_sourcedir/<font-tarball> -C ${RPM_BUILD_ROOT}/usr/share/ghostscript --no-same-owner


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
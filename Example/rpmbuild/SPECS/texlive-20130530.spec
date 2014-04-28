%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     A binary version of the TeX Live package is installed at install-tl-unx. Here, we use that to rebuild the compiled programs from source. 
Name:       texlive
Version:    20130530
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  freeglut
Requires:  ghostscript
Requires:  x-window-system-environment
Requires:  ruby
Requires:  tk
Source0:    ftp://tug.org/texlive/historic/2013/texlive-20130530-source.tar.xz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/texlive-20130530-source-fix_asymptote-1.patch
URL:        ftp://tug.org/texlive/historic/2013
%description
 A binary version of the TeX Live package is installed at install-tl-unx. Here, we use that to rebuild the compiled programs from source. 
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
patch -Np1 -i %_sourcedir/texlive-20130530-source-fix_asymptote-1.patch &&
mkdir -pv texlive-build &&
cd texlive-build    &&
../configure --prefix=/opt/texlive/2013 --bindir=/opt/texlive/2013/bin/x86_64-linux --datarootdir=/opt/texlive/2013 --includedir=/usr/include --infodir=/opt/texlive/2013/texmf-dist/doc/info --libdir=/usr/lib --mandir=/opt/texlive/2013/texmf-dist/doc/man --disable-native-texlive-build --disable-static --enable-shared --with-system-libgs --with-system-poppler --with-system-freetype2 --with-system-fontconfig --with-system-libpng --with-system-icu --with-system-graphite2 --with-system-harfbuzz --with-system-xpdf --with-system-poppler --with-system-cairo --with-system-pixman --with-system-zlib --with-banner-add=" - BLFS" &&
pushd  %_sourcedir/utils/asymptote &&
    echo "ac_cv_lib_m_sqrt=yes"     >config.cache &&
    echo "ac_cv_lib_z_deflate=yes" >>config.cache &&
./configure LIBS="-ltirpc " --prefix=/opt/texlive/2013/ --bindir=/opt/texlive/2013/bin/x86_64-linux --enable-texlive-build --datarootdir=/opt/texlive/2013/texmf-dist --infodir=/opt/texlive/2013/texmf-dist/doc/info --mandir=/opt/texlive/2013/texmf-dist/doc/man --cache-file=config.cache &&
popd &&
make && %{?_smp_mflags} 

make -C ../utils/asymptote %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd texlive-build    &&


make install && DESTDIR=${RPM_BUILD_ROOT} 

make -C ../utils/asymptote install DESTDIR=${RPM_BUILD_ROOT} 


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
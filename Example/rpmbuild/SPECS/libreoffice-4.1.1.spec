%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     LibreOffice is a full-featured office suite. It is largely compatible with Microsoft Office and is descended from OpenOffice.org. 
Name:       libreoffice
Version:    4.1.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gperf
Requires:  gtk
Requires:  archive-zip
Requires:  xml-parser
Requires:  unzip
Requires:  wget
Requires:  which
Requires:  zip
Requires:  boost
Requires:  cups
Requires:  curl
Requires:  d-bus
Requires:  expat
Requires:  gst-plugins-base
Requires:  icu
Requires:  little-cms
Requires:  librsvg
Requires:  libxml2
Requires:  libxslt
Requires:  mesalib
Requires:  neon
Requires:  nss
Requires:  openldap
Requires:  openssl
Requires:  poppler
Requires:  python
Requires:  redland
Requires:  unixodbc
Source0:    http://download.documentfoundation.org/libreoffice/src/4.1.1/libreoffice-4.1.1.2.tar.xz
Source1:    http://download.documentfoundation.org/libreoffice/src/4.1.1/libreoffice-dictionaries-4.1.1.2.tar.xz
Source2:    http://download.documentfoundation.org/libreoffice/src/4.1.1/libreoffice-help-4.1.1.2.tar.xz
Source3:    http://download.documentfoundation.org/libreoffice/src/4.1.1/libreoffice-translations-4.1.1.2.tar.xz
Source4:    http://www.linuxfromscratch.org/patches/blfs/svn/libreoffice-4.1.1.2-system_neon-1.patch
URL:        http://download.documentfoundation.org/libreoffice/src/4.1.1
%description
 LibreOffice is a full-featured office suite. It is largely compatible with Microsoft Office and is descended from OpenOffice.org. 
%pre
install -dm755 src 
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
tar -xf libreoffice-4.1.1.2.tar.xz --no-overwrite-dir 
cd libreoffice-4.1.1.2
tar -xf  %_sourcedir/libreoffice-dictionaries-4.1.1.2.tar.xz --no-overwrite-dir --strip-components=1 
ln -sv ../../libreoffice-dictionaries-4.1.1.2.tar.xz src/ 
ln -sv ../../libreoffice-help-4.1.1.2.tar.xz src/
ln -sv ../../libreoffice-translations-4.1.1.2.tar.xz src/
sed -e "/gzip -f/d" -e "s|.1.gz|.1|g" -i bin/distro-install-desktop-integration 
sed -e "/distro-install-file-lists/d" -i Makefile.in 
chmod -v +x bin/unpack-sources 
sed -e "s/target\.mk/langlist\.mk/" -e "s/tar -xf/tar -x --strip-components=1 -f/" -e "/tar -x/s/lo_src_dir/start_dir/" -i bin/unpack-sources 
patch -Np1 -i %_sourcedir/libreoffice-4.1.1.2-system_neon-1.patch    
./autogen.sh --prefix=/usr --sysconfdir=/etc --with-vendor="BLFS" --with-lang="en-US pt-BR" --with-help --with-alloc=system --without-java --disable-gconf --disable-odk --disable-postgresql-sdbc --enable-python=system --with-system-boost --with-system-cairo --with-system-curl --with-system-expat --with-system-harfbuzz --with-system-icu --with-system-jpeg --with-system-lcms2 --with-system-libpng --with-system-libxml --with-system-mesa-headers --with-system-neon --with-system-nss --with-system-odbc --with-system-openldap --with-system-openssl --with-system-poppler --with-system-redland --with-system-zlib --with-parallelism=$(getconf _NPROCESSORS_ONLN)
make build %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd libreoffice-4.1.1.2

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/libreoffice/share/extensions
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps/
mkdir -pv ${RPM_BUILD_ROOT}/opt/libreoffice-4.1.1.2/share/icons/hicolor/32x32/apps
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
make distro-pack-install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/libreoffice/share/extensions/dict-en                      

cp -vR dictionaries/en/*    ${RPM_BUILD_ROOT}/usr/lib/libreoffice/share/extensions/dict-en    

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/lib/libreoffice/share/extensions/dict-pt-BR                   

cp -vR dictionaries/pt_BR/* ${RPM_BUILD_ROOT}/usr/lib/libreoffice/share/extensions/dict-pt-BR

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps 

for i in writer base calc draw impress math startcenter writer
do
  ln -svf ${RPM_BUILD_ROOT}/opt/libreoffice-4.1.1.2/share/icons/hicolor/32x32/apps/libreoffice-$i.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/

done
unset i

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -cR 0:0 dictionaries/                                                  
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
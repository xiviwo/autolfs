%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     LibreOffice is a full-featured office suite. It is largely compatible with Microsoft Office and is descended from OpenOffice.org. 
Name:       libreoffice
Version:    4.2.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gperf
Requires:  archive-zip
Requires:  unzip
Requires:  wget
Requires:  which
Requires:  zip
Requires:  libjpeg-turbo
Requires:  glu
Requires:  gtk
Requires:  boost
Requires:  clucene
Requires:  cups
Requires:  curl
Requires:  d-bus
Requires:  expat
Requires:  graphite2
Requires:  gst-plugins-base
Requires:  harfbuzz
Requires:  icu
Requires:  little-cms
Requires:  librsvg
Requires:  libxml2
Requires:  libxslt
Requires:  mesalib
Requires:  neon
Requires:  npapi-sdk
Requires:  nss
Requires:  openldap
Requires:  openssl
Requires:  poppler
Requires:  python
Requires:  redland
Requires:  unixodbc
Source0:    http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-4.2.0.4.tar.xz
Source1:    http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-dictionaries-4.2.0.4.tar.xz
Source2:    http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-help-4.2.0.4.tar.xz
Source3:    http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-translations-4.2.0.4.tar.xz
URL:        http://download.documentfoundation.org/libreoffice/src/4.2.0
%description
 LibreOffice is a full-featured office suite. It is largely compatible with Microsoft Office and is descended from OpenOffice.org. 
%pre
install -dm755 src &&
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
tar -xf libreoffice-4.2.0.4.tar.xz --no-overwrite-dir &&
cd libreoffice-4.2.0.4
tar -xf  %_sourcedir/libreoffice-dictionaries-4.2.0.4.tar.xz --no-overwrite-dir --strip-components=1 &&
ln -svf  %_sourcedir/../libreoffice-dictionaries-4.2.0.4.tar.xz src/ &&
ln -svf  %_sourcedir/../libreoffice-help-4.2.0.4.tar.xz src/
ln -svf  %_sourcedir/../libreoffice-translations-4.2.0.4.tar.xz src/
export LO_PREFIX=<PREFIX>
sed -e "/gzip -f/d" -e "s|.1.gz|.1|g" -i bin/distro-install-desktop-integration        &&
sed -e "/distro-install-file-lists/d" -i Makefile.in &&
chmod -v +x bin/unpack-sources                     &&
sed -e "s/target\.mk/langlist\.mk/" -e "s/tar -xf/tar -x --strip-components=1 -f/" -e "/tar -x/s/lo_src_dir/start_dir/" -i bin/unpack-sources                          &&
./autogen.sh --prefix=$LO_PREFIX --sysconfdir=/etc --with-vendor="BLFS" --with-lang="en-US pt-BR" --with-help --with-alloc=system --without-java --disable-gconf --disable-odk --disable-postgresql-sdbc --enable-release-build=yes --enable-python=system --with-system-boost --with-system-clucene --with-system-cairo --with-system-curl --with-system-expat --with-system-graphite --with-system-harfbuzz --with-system-icu --with-system-jpeg --with-system-lcms2 --with-system-libpng --with-system-libxml --with-system-mesa-headers --with-system-neon --with-system-npapi-headers --with-system-nss --with-system-odbc --with-system-openldap --with-system-openssl --with-system-poppler --with-system-redland --with-system-zlib --with-parallelism=$(getconf _NPROCESSORS_ONLN)
make build %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd libreoffice-4.2.0.4

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps/
mkdir -pv ${RPM_BUILD_ROOT}/opt/libreoffice-4.2.0.4/share/icons/hicolor/32x32/apps
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
make distro-pack-install                                    && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d $LO_PREFIX/share/appdata                &&
install -v -m644    sysui/desktop/appstream-appdata/*.xml $LO_PREFIX/share/appdata
mkdir -pv -pv $LO_PREFIX/lib/libreoffice/share/extensions/dict-en                      &&
cp -vR dictionaries/en/*    $LO_PREFIX/lib/libreoffice/share/extensions/dict-en    &&
mkdir -pv -pv $LO_PREFIX/lib/libreoffice/share/extensions/dict-pt-BR                   &&
cp -vR dictionaries/pt_BR/* $LO_PREFIX/lib/libreoffice/share/extensions/dict-pt-BR
mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps &&

for i in writer base calc draw impress math startcenter writer
do
  ln -svf ${RPM_BUILD_ROOT}/opt/libreoffice-4.2.0.4/share/icons/hicolor/32x32/apps/libreoffice-$i.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/

done
unset i

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -cR 0:0 dictionaries/                                                        &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
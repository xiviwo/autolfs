%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     a2ps is a filter utilized mainly in the background and primarily by printing scripts to convert almost every input format into PostScript output. The application's name expands appropriately to “all to PostScript”. 
Name:       a2ps
Version:    4.14
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gperf
Requires:  psutils-p17-p17
Requires:  cups
Source0:    http://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/a2ps/a2ps-4.14.tar.gz
Source2:    http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/i18n-fonts/i18n-fonts-0.1.tar.bz2
URL:        http://ftp.gnu.org/gnu/a2ps
%description
 a2ps is a filter utilized mainly in the background and primarily by printing scripts to convert almost every input format into PostScript output. The application's name expands appropriately to “all to PostScript”. 
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
autoconf &&
sed -i -e "s/GPERF --version |/& head -n 1 |/" -e "s|/usr/local/share|/usr/share|" configure &&
./configure --prefix=/usr --sysconfdir=/etc/a2ps --enable-shared --with-medium=letter   &&
make                       && %{?_smp_mflags} 

touch doc/*.info

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/a2ps/afm
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/a2ps/fonts
make install DESTDIR=${RPM_BUILD_ROOT} 

tar -xf  %_sourcedir/i18n-fonts-0.1.tar.bz2 &&
cp -v i18n-fonts-0.1/fonts/* ${RPM_BUILD_ROOT}/usr/share/a2ps/fonts               &&

cp -v i18n-fonts-0.1/afm/* ${RPM_BUILD_ROOT}/usr/share/a2ps/afm                   &&

pushd ${RPM_BUILD_ROOT}/usr/share/a2ps/afm    &&

  ./make_fonts_map.sh        &&
  mv fonts.map.new fonts.map &&
popd

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
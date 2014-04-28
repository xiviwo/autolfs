%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libpng package contains libraries used by other programs for reading and writing PNG files. The PNG format was designed as a replacement for GIF and, to a lesser extent, TIFF, with many improvements and extensions and lack of patent problems. 
Name:       libpng
Version:    1.6.4
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/libpng/libpng-1.6.4.tar.xz
Source1:    http://downloads.sourceforge.net/libpng-apng/libpng-1.6.3-apng.patch.gz
URL:        http://downloads.sourceforge.net/libpng
%description
 The libpng package contains libraries used by other programs for reading and writing PNG files. The PNG format was designed as a replacement for GIF and, to a lesser extent, TIFF, with many improvements and extensions and lack of patent problems. 
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
gzip -cd  %_sourcedir/libpng-1.6.3-apng.patch.gz | patch -p1
./configure --prefix=/usr --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libpng-1.6.4
make install  DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libpng-1.6.4 

cp -v README libpng-manual.txt ${RPM_BUILD_ROOT}/usr/share/doc/libpng-1.6.4


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
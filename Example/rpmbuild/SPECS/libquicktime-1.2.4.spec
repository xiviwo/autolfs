%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libquicktime package contains the libquicktime library, various plugins and codecs, along with graphical and command line utilities used for encoding and decoding QuickTime files. This is useful for reading and writing files in the QuickTime format. The goal of the project is to enhance, while providing compatibility with the Quicktime 4 Linux library. 
Name:       libquicktime
Version:    1.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/libquicktime/libquicktime-1.2.4.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/libquicktime-1.2.4-ffmpeg2-1.patch
URL:        http://downloads.sourceforge.net/libquicktime
%description
 The libquicktime package contains the libquicktime library, various plugins and codecs, along with graphical and command line utilities used for encoding and decoding QuickTime files. This is useful for reading and writing files in the QuickTime format. The goal of the project is to enhance, while providing compatibility with the Quicktime 4 Linux library. 
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
patch -Np1 -i %_sourcedir/libquicktime-1.2.4-ffmpeg2-1.patch &&
./configure --prefix=/usr --enable-gpl --without-doxygen --docdir=/usr/share/doc/libquicktime-1.2.4
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/libquicktime-1.2.4 &&

install -v -m644    README doc/{*.txt,*.html,mainpage.incl} ${RPM_BUILD_ROOT}/usr/share/doc/libquicktime-1.2.4


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
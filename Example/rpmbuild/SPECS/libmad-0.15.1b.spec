%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libmad is a high-quality MPEG audio decoder capable of 24-bit output. 
Name:       libmad
Version:    0.15.1b
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/mad/libmad-0.15.1b.tar.gz
Source1:    ftp://ftp.mars.org/pub/mpeg/libmad-0.15.1b.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/libmad-0.15.1b-fixes-1.patch
URL:        http://downloads.sourceforge.net/mad
%description
 libmad is a high-quality MPEG audio decoder capable of 24-bit output. 
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
patch -Np1 -i %_sourcedir/libmad-0.15.1b-fixes-1.patch                &&
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac &&
touch NEWS AUTHORS ChangeLog                                 &&
autoreconf -fi                                               &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/pkgconfig
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /usr/lib/pkgconfig/mad.pc << "EOF"
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
Name: mad
Description: MPEG audio decoder
Requires:
Version: 0.15.1b
Libs: -L${libdir} -lmad
Cflags: -I${includedir}
EOF

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
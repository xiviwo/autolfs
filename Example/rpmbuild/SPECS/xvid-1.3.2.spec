%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     XviD is an MPEG-4 compliant video CODEC. 
Name:       xvid
Version:    1.3.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
URL:        http://downloads.xvid.org/downloads
%description
 XviD is an MPEG-4 compliant video CODEC. 
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
cd build/generic &&
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build/generic &&

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/xvidcore-1.3.2
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
sed -i '/libdir.*STATIC_LIB/ s/^/#/' Makefile &&
make install && DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf libxvidcore.so.4.3 ${RPM_BUILD_ROOT}/usr/lib/libxvidcore.so.4 &&

ln -v -sf libxvidcore.so.4   ${RPM_BUILD_ROOT}/usr/lib/libxvidcore.so   &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/xvidcore-1.3.2/examples &&

install -v -m644 ../../doc/* ${RPM_BUILD_ROOT}/usr/share/doc/xvidcore-1.3.2 &&

install -v -m644 ../../examples/* ${RPM_BUILD_ROOT}/usr/share/doc/xvidcore-1.3.2/examples


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libxvidcore.so.4.3 &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
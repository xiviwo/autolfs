%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libmng libraries are used by programs wanting to read and write Multiple-image Network Graphics (MNG) files which are the animation equivalents to PNG files. 
Name:       libmng
Version:    2.0.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libjpeg-turbo
Requires:  little-cms
Source0:    http://downloads.sourceforge.net/libmng/libmng-2.0.2.tar.xz
URL:        http://downloads.sourceforge.net/libmng
%description
 The libmng libraries are used by programs wanting to read and write Multiple-image Network Graphics (MNG) files which are the animation equivalents to PNG files. 
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
sed -i "s:#include <jpeg:#include <stdio.h>\n&:" libmng_types.h &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libmng-2.0.2
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d        ${RPM_BUILD_ROOT}/usr/share/doc/libmng-2.0.2 &&

install -v -m644 doc/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/libmng-2.0.2


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
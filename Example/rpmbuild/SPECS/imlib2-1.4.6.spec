%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Imlib2 is a graphics library for fast file loading, saving, rendering and manipulation. 
Name:       imlib2
Version:    1.4.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  xorg-libraries
Source0:    http://downloads.sourceforge.net/enlightenment/imlib2-1.4.6.tar.bz2
URL:        http://downloads.sourceforge.net/enlightenment
%description
 Imlib2 is a graphics library for fast file loading, saving, rendering and manipulation. 
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
sed -i '/DGifOpen/s:fd:&, NULL:' src/modules/loaders/loader_gif.c &&
sed -i 's/@my_libs@//' imlib2-config.in &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/imlib2-1.4.6 &&

install -v -m644    doc/{*.gif,index.html} ${RPM_BUILD_ROOT}/usr/share/doc/imlib2-1.4.6


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
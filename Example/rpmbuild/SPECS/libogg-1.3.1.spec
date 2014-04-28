%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libogg package contains the Ogg file structure. This is useful for creating (encoding) or playing (decoding) a single physical bit stream. 
Name:       libogg
Version:    1.3.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.xz
Source1:    ftp://downloads.xiph.org/pub/xiph/releases/ogg/libogg-1.3.1.tar.xz
URL:        http://downloads.xiph.org/releases/ogg
%description
 The libogg package contains the Ogg file structure. This is useful for creating (encoding) or playing (decoding) a single physical bit stream. 
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
./configure --prefix=/usr --docdir=/usr/share/doc/libogg-1.3.1 --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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
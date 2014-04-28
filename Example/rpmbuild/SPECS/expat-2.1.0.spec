%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Expat package contains a stream oriented C library for parsing XML. 
Name:       expat
Version:    2.1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz
URL:        http://downloads.sourceforge.net/expat
%description
 The Expat package contains a stream oriented C library for parsing XML. 
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
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/expat-2.1.0
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/expat-2.1.0 &&

install -v -m644 doc/*.{html,png,css} ${RPM_BUILD_ROOT}/usr/share/doc/expat-2.1.0


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
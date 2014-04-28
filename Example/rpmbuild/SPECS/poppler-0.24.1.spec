%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Poppler package contains a PDF rendering library and command line tools used to manipulate PDF files. This is useful for providing PDF rendering functionality as a shared library. 
Name:       poppler
Version:    0.24.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  fontconfig
Requires:  cairo
Requires:  libjpeg-turbo
Requires:  libpng
Source0:    http://poppler.freedesktop.org/poppler-0.24.1.tar.xz
Source1:    http://poppler.freedesktop.org/poppler-data-0.4.6.tar.gz
URL:        http://poppler.freedesktop.org
%description
 The Poppler package contains a PDF rendering library and command line tools used to manipulate PDF files. This is useful for providing PDF rendering functionality as a shared library. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-xpdf-headers 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d      ${RPM_BUILD_ROOT}/usr/share/doc/poppler-0.24.1 

install -v -m644 README* ${RPM_BUILD_ROOT}/usr/share/doc/poppler-0.24.1

tar -xf  %_sourcedir/poppler-data-0.4.6.tar.gz 
cd poppler-data-0.4.6
make prefix=${RPM_BUILD_ROOT}/usr install DESTDIR=${RPM_BUILD_ROOT} 


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
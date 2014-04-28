%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libjpeg-turbo is a fork of the original IJG libjpeg which uses SIMD to accelerate baseline JPEG compression and decompression. libjpeg is a library that implements JPEG image encoding, decoding and transcoding. 
Name:       libjpeg-turbo
Version:    1.3.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  nasm
Source0:    http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.3.0.tar.gz
URL:        http://downloads.sourceforge.net/libjpeg-turbo
%description
 libjpeg-turbo is a fork of the original IJG libjpeg which uses SIMD to accelerate baseline JPEG compression and decompression. libjpeg is a library that implements JPEG image encoding, decoding and transcoding. 
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
./configure --prefix=/usr --mandir=/usr/share/man --with-jpeg8 --disable-static &&
sed -i -e '/^docdir/ s/$/\/libjpeg-turbo-1.3.0/' -e '/^exampledir/ s/$/\/libjpeg-turbo-1.3.0/' Makefile &&
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
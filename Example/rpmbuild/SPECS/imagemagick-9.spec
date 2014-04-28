%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     ImageMagick is a collection of tools and libraries to read, write, and manipulate an image in various image formats. Image processing operations are available from the command line. Bindings for Perl and C++ are also available. 
Name:       imagemagick
Version:    9
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  x-window-system-environment
Source0:    ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.8.6-9.tar.xz
URL:        ftp://ftp.imagemagick.org/pub/ImageMagick
%description
 ImageMagick is a collection of tools and libraries to read, write, and manipulate an image in various image formats. Image processing operations are available from the command line. Bindings for Perl and C++ are also available. 
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
./configure --prefix=/usr --sysconfdir=/etc --with-modules --with-perl --disable-static  
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
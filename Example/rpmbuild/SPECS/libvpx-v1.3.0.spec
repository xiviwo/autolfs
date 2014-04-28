%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     This package, from the WebM project, provides the reference implementations of the VP8 Codec, used in most current html5 video, and of the next-generation VP9 Codec. 
Name:       libvpx
Version:    v1.3.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  yasm
Requires:  nasm
Requires:  which
Source0:    http://anduin.linuxfromscratch.org/sources/other/libvpx-v1.3.0.tar.xz
URL:        http://anduin.linuxfromscratch.org/sources/other
%description
 This package, from the WebM project, provides the reference implementations of the VP8 Codec, used in most current html5 video, and of the next-generation VP9 Codec. 
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
sed -i 's/cp -p/cp/' build/make/Makefile &&
chmod -v 644 vpx/*.h &&
mkdir -pv ../libvpx-build &&
cd  %_sourcedir/libvpx-build &&
../libvpx-v1.3.0/configure --prefix=/usr --enable-shared --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ../libvpx-build &&


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
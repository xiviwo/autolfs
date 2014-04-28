%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Mesa is an OpenGL compatible 3D graphics library. 
Name:       mesalib
Version:    10.0.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxml2
Requires:  xorg-libraries
Requires:  libdrm
Requires:  expat
Requires:  elfutils
Requires:  libvdpau
Requires:  llvm
Source0:    ftp://ftp.freedesktop.org/pub/mesa/10.0.3/MesaLib-10.0.3.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/MesaLib-10.0.3-add_xdemos-1.patch
URL:        ftp://ftp.freedesktop.org/pub/mesa/10.0.3
%description
 Mesa is an OpenGL compatible 3D graphics library. 
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
patch -Np1 -i %_sourcedir/MesaLib-10.0.3-add_xdemos-1.patch
./autogen.sh CFLAGS="-O2" CXXFLAGS="-O2" --prefix=$XORG_PREFIX --sysconfdir=/etc --enable-texture-float --enable-gles1 --enable-gles2 --enable-openvg --enable-osmesa --enable-xa --enable-gbm --enable-gallium-egl --enable-gallium-gbm --enable-glx-tls --with-llvm-shared-libs --with-egl-platforms="drm,x11" --with-gallium-drivers="nouveau,r300,r600,radeonsi,svga,swrast" &&
make %{?_smp_mflags} 
make -C xdemos DEMOS_PREFIX=$XORG_PREFIX %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/MesaLib-10.0.3
make install DESTDIR=${RPM_BUILD_ROOT} 

make -C xdemos DEMOS_PREFIX=$XORG_PREFIX install DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755 ${RPM_BUILD_ROOT}/usr/share/doc/MesaLib-10.0.3 &&

cp -rfv docs/* ${RPM_BUILD_ROOT}/usr/share/doc/MesaLib-10.0.3


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
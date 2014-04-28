%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Opal package contains a C++ class library for normalising the numerous telephony protocols into a single integrated call model. 
Name:       opal
Version:    3.10.10
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  ptlib
Source0:    http://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/opal-3.10.10-ffmpeg2-1.patch
URL:        http://ftp.gnome.org/pub/gnome/sources/opal/3.10
%description
 The Opal package contains a C++ class library for normalising the numerous telephony protocols into a single integrated call model. 
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
patch -Np1 -i %_sourcedir/opal-3.10.10-ffmpeg2-1.patch &&
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 644 /usr/lib/libopal_s.a
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
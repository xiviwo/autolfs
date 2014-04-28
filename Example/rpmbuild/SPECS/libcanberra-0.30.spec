%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libcanberra is an implementation of the XDG Sound Theme and Name Specifications, for generating event sounds on free desktops, such as GNOME. 
Name:       libcanberra
Version:    0.30
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libvorbis
Requires:  alsa-lib
Requires:  gstreamer
Requires:  gtk
Source0:    http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz
URL:        http://0pointer.de/lennart/projects/libcanberra
%description
 libcanberra is an implementation of the XDG Sound Theme and Name Specifications, for generating event sounds on free desktops, such as GNOME. 
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
./configure --prefix=/usr --disable-oss &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docdir=${RPM_BUILD_ROOT}/usr/share/doc/libcanberra-0.30 install DESTDIR=${RPM_BUILD_ROOT} 


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
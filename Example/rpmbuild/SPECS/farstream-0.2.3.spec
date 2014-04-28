%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Farstream package contains libraries and a collection of GStreamer modules used for video conferencing. 
Name:       farstream
Version:    0.2.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  libnice
Requires:  gobject-introspection
Requires:  gst-plugins-bad
Requires:  gst-plugins-good
Source0:    http://freedesktop.org/software/farstream/releases/farstream/farstream-0.2.3.tar.gz
URL:        http://freedesktop.org/software/farstream/releases/farstream
%description
 The Farstream package contains libraries and a collection of GStreamer modules used for video conferencing. 
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
./configure --prefix=/usr &&
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
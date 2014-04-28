%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     x264 package provides a library for encoding video streams into the H.264/MPEG-4 AVC format. 
Name:       x264
Version:    20140115
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  yasm
Source0:    ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20140115-2245-stable.tar.bz2
URL:        ftp://ftp.videolan.org/pub/videolan/x264/snapshots
%description
 x264 package provides a library for encoding video streams into the H.264/MPEG-4 AVC format. 
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
./configure --prefix=/usr --enable-shared --disable-cli &&
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
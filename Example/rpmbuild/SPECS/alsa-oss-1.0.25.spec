%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ALSA OSS package contains the ALSA OSS compatibility library. This is used by programs which wish to use the ALSA OSS sound interface. 
Name:       alsa-oss
Version:    1.0.25
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Source0:    http://alsa.cybermirror.org/oss-lib/alsa-oss-1.0.25.tar.bz2
Source1:    ftp://ftp.alsa-project.org/pub/oss-lib/alsa-oss-1.0.25.tar.bz2
URL:        http://alsa.cybermirror.org/oss-lib
%description
 The ALSA OSS package contains the ALSA OSS compatibility library. This is used by programs which wish to use the ALSA OSS sound interface. 
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
./configure --disable-static &&
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Hdparm package contains an utility that is useful for controlling ATA/IDE controllers and hard drives both to increase performance and sometimes to increase stability. 
Name:       hdparm
Version:    9.43
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/hdparm/hdparm-9.43.tar.gz
URL:        http://downloads.sourceforge.net/hdparm
%description
 The Hdparm package contains an utility that is useful for controlling ATA/IDE controllers and hard drives both to increase performance and sometimes to increase stability. 
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
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 

make binprefix=${RPM_BUILD_ROOT}/usr install DESTDIR=${RPM_BUILD_ROOT} 


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
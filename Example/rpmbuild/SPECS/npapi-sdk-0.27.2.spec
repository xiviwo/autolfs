%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     NPAPI-SDK is a bundle of Netscape Plugin Application Programming Interface headers by Mozilla. This package provides a clear way to install those headers and depend on them. 
Name:       npapi-sdk
Version:    0.27.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    https://bitbucket.org/mgorny/npapi-sdk/downloads/npapi-sdk-0.27.2.tar.bz2
URL:        https://bitbucket.org/mgorny/npapi-sdk/downloads
%description
 NPAPI-SDK is a bundle of Netscape Plugin Application Programming Interface headers by Mozilla. This package provides a clear way to install those headers and depend on them. 
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
./configure --prefix=/usr

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
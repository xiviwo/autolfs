%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Opus is a lossy audio compression format developed by the Internet Engineering Task Force (IETF) that is particularly suitable for interactive speech and audio transmission over the Internet. This package provides the Opus development library and headers. 
Name:       opus
Version:    1.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
URL:        http://downloads.xiph.org/releases/opus
%description
 Opus is a lossy audio compression format developed by the Internet Engineering Task Force (IETF) that is particularly suitable for interactive speech and audio transmission over the Internet. This package provides the Opus development library and headers. 
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
./configure --prefix=/usr --disable-static &&
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
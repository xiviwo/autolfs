%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ISO Codes package contains a list of country, language and currency names and it is used as a central database for accessing this data. 
Name:       iso-codes
Version:    3.46
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://pkg-isocodes.alioth.debian.org/downloads/iso-codes-3.46.tar.xz
URL:        http://pkg-isocodes.alioth.debian.org/downloads
%description
 The ISO Codes package contains a list of country, language and currency names and it is used as a central database for accessing this data. 
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
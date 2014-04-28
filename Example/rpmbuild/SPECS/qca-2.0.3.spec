%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Qca aims to provide a straightforward and cross-platform crypto API, using Qt datatypes and conventions. Qca separates the API from the implementation, using plugins known as Providers. 
Name:       qca
Version:    2.0.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  qt
Requires:  which
Source0:    http://delta.affinix.com/download/qca/2.0/qca-2.0.3.tar.bz2
URL:        http://delta.affinix.com/download/qca/2.0
%description
 Qca aims to provide a straightforward and cross-platform crypto API, using Qt datatypes and conventions. Qca separates the API from the implementation, using plugins known as Providers. 
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
sed -i '217s@set@this->set@' src/botantools/botan/botan/secmem.h &&
./configure --prefix=$QTDIR --certstore-path=/etc/ssl/ca-bundle.crt --no-separate-debug-info &&
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
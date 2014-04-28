%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libtasn1 is a highly portable C library that encodes and decodes DER/BER data following an ASN.1 schema. 
Name:       libtasn1
Version:    3.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/libtasn1/libtasn1-3.3.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/libtasn1/libtasn1-3.3.tar.gz
URL:        http://ftp.gnu.org/gnu/libtasn1
%description
 libtasn1 is a highly portable C library that encodes and decodes DER/BER data following an ASN.1 schema. 
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
./configure --prefix=/usr --disable-static 
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
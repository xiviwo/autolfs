%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libgcrypt package contains a general purpose crypto library based on the code used in GnuPG. The library provides a high level interface to cryptographic building blocks using an extendable and flexible API. 
Name:       libgcrypt
Version:    1.5.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libgpg-error
Source0:    ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.3.tar.bz2
URL:        ftp://ftp.gnupg.org/gcrypt/libgcrypt
%description
 The libgcrypt package contains a general purpose crypto library based on the code used in GnuPG. The library provides a high level interface to cryptographic building blocks using an extendable and flexible API. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libgcrypt-1.5.3
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -dm755   ${RPM_BUILD_ROOT}/usr/share/doc/libgcrypt-1.5.3 

install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} ${RPM_BUILD_ROOT}/usr/share/doc/libgcrypt-1.5.3


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
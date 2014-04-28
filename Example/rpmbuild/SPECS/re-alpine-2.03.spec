%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Re-alpine is the continuation of Alpine; a text-based email client developed by the University of Washington. 
Name:       re-alpine
Version:    2.03
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://sourceforge.net/projects/re-alpine/files/re-alpine-2.03.tar.bz2
URL:        http://sourceforge.net/projects/re-alpine/files
%description
 Re-alpine is the continuation of Alpine; a text-based email client developed by the University of Washington. 
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
./configure --prefix=/usr --sysconfdir=/etc --without-ldap --without-krb5 --with-ssl-dir=/usr --with-passfile=.pine-passfile &&
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
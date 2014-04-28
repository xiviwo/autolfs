%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Rarian package is a documentation metadata library based on the proposed Freedesktop.org spec. Rarian is designed to be a replacement for ScrollKeeper. 
Name:       rarian
Version:    0.8.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxslt
Requires:  docbook-xml
Source0:    http://ftp.gnome.org/pub/gnome/sources/rarian/0.8/rarian-0.8.1.tar.bz2
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/rarian/0.8/rarian-0.8.1.tar.bz2
URL:        http://ftp.gnome.org/pub/gnome/sources/rarian/0.8
%description
 The Rarian package is a documentation metadata library based on the proposed Freedesktop.org spec. Rarian is designed to be a replacement for ScrollKeeper. 
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
./configure --prefix=/usr --localstatedir=/var &&
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
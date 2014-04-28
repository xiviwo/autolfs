%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     ldns is a fast DNS library with the goal to simplify DNS programming and to allow developers to easily create software conforming to current RFCs and Internet drafts. This packages also includes the drill tool. 
Name:       ldns
Version:    1.6.16
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://www.nlnetlabs.nl/downloads/ldns/ldns-1.6.16.tar.gz
URL:        http://www.nlnetlabs.nl/downloads/ldns
%description
 ldns is a fast DNS library with the goal to simplify DNS programming and to allow developers to easily create software conforming to current RFCs and Internet drafts. This packages also includes the drill tool. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-static --with-drill      
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
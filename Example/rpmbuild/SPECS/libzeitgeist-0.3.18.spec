%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libzeitgeist package contains a client library used to access and manage the Zeitgeist event log from languages such as C and Vala. Zeitgeist is a service which logs the user's activities and events (files opened, websites visited, conversations hold with other people, etc.) and makes the relevant information available to other applications. 
Name:       libzeitgeist
Version:    0.3.18
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Source0:    https://launchpad.net/libzeitgeist/0.3/0.3.18/+download/libzeitgeist-0.3.18.tar.gz
URL:        https://launchpad.net/libzeitgeist/0.3/0.3.18/+download
%description
 The libzeitgeist package contains a client library used to access and manage the Zeitgeist event log from languages such as C and Vala. Zeitgeist is a service which logs the user's activities and events (files opened, websites visited, conversations hold with other people, etc.) and makes the relevant information available to other applications. 
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
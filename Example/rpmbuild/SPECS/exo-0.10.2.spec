%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Exo is a support library used in the Xfce desktop. It also has some helper applications that are used throughout Xfce. 
Name:       exo
Version:    0.10.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxfce4ui
Requires:  libxfce4util
Requires:  uri
Source0:    http://archive.xfce.org/src/xfce/exo/0.10/exo-0.10.2.tar.bz2
URL:        http://archive.xfce.org/src/xfce/exo/0.10
%description
 Exo is a support library used in the Xfce desktop. It also has some helper applications that are used throughout Xfce. 
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
./configure --prefix=/usr --sysconfdir=/etc &&
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Ristretto is a fast and lightweight image viewer for the Xfce desktop. 
Name:       ristretto
Version:    0.6.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libexif
Requires:  libxfce4ui
Source0:    http://archive.xfce.org/src/apps/ristretto/0.6/ristretto-0.6.3.tar.bz2
URL:        http://archive.xfce.org/src/apps/ristretto/0.6
%description
 Ristretto is a fast and lightweight image viewer for the Xfce desktop. 
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
./configure --prefix=/usr &&
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
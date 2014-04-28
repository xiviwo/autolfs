%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GNOME Icon Theme Extras package contains extra icons for the GNOME Desktop. 
Name:       gnome-icon-theme-extras
Version:    3.6.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gnome-icon-theme
Source0:    http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-extras/3.6/gnome-icon-theme-extras-3.6.2.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-extras/3.6/gnome-icon-theme-extras-3.6.2.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme-extras/3.6
%description
 The GNOME Icon Theme Extras package contains extra icons for the GNOME Desktop. 
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
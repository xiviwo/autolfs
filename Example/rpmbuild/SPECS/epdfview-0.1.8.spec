%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     ePDFView is a free standalone lightweight PDF document viewer using Poppler and GTK+ libraries. It is a good replacement for Evince as it does not rely upon GNOME libraries. 
Name:       epdfview
Version:    0.1.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  poppler
Requires:  gtk
Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/epdfview/epdfview-0.1.8.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/epdfview-0.1.8-fixes-1.patch
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/epdfview
%description
 ePDFView is a free standalone lightweight PDF document viewer using Poppler and GTK+ libraries. It is a good replacement for Evince as it does not rely upon GNOME libraries. 
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
patch -Np1 -i %_sourcedir/epdfview-0.1.8-fixes-1.patch &&
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
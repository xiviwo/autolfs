%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The rep-gtk package contains a Lisp and GTK binding. This is useful for extending GTK-2 and GDK libraries with Lisp. Starting at rep-gtk-0.15, the package contains the bindings to GTK and uses the same instructions. Both can be installed, if needed. 
Name:       rep-gtk
Version:    0.90.8.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libglade
Requires:  librep
Source0:    http://download.tuxfamily.org/librep/rep-gtk/rep-gtk-0.90.8.1.tar.xz
URL:        http://download.tuxfamily.org/librep/rep-gtk
%description
 The rep-gtk package contains a Lisp and GTK binding. This is useful for extending GTK-2 and GDK libraries with Lisp. Starting at rep-gtk-0.15, the package contains the bindings to GTK and uses the same instructions. Both can be installed, if needed. 
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
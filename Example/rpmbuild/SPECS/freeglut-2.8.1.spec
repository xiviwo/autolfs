%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Freeglut is intended to be a 100% compatible, completely opensourced clone of the GLUT library. GLUT is a window system independent toolkit for writing OpenGL programs, implementing a simple windowing API, which makes learning about and exploring OpenGL programming very easy. 
Name:       freeglut
Version:    2.8.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glu
Source0:    http://downloads.sourceforge.net/freeglut/freeglut-2.8.1.tar.gz
URL:        http://downloads.sourceforge.net/freeglut
%description
 Freeglut is intended to be a 100% compatible, completely opensourced clone of the GLUT library. GLUT is a window system independent toolkit for writing OpenGL programs, implementing a simple windowing API, which makes learning about and exploring OpenGL programming very easy. 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Graphviz package contains graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. Graphviz has several main graph layout programs. It also has web and interactive graphical interfaces, auxiliary tools, libraries, and language bindings. 
Name:       graphviz
Version:    2.34.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  expat
Requires:  freetype
Requires:  fontconfig
Requires:  freeglut
Requires:  gdk-pixbuf
Requires:  libjpeg-turbo
Requires:  libpng
Requires:  librsvg
Requires:  pango
Requires:  xorg-libraries
Source0:    http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.34.0.tar.gz
URL:        http://graphviz.org/pub/graphviz/stable/SOURCES
%description
 The Graphviz package contains graph visualization software. Graph visualization is a way of representing structural information as diagrams of abstract graphs and networks. Graphviz has several main graph layout programs. It also has web and interactive graphical interfaces, auxiliary tools, libraries, and language bindings. 
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
./configure --prefix=/usr --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/graphviz
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -v -s ${RPM_BUILD_ROOT}/usr/share/graphviz/doc ${RPM_BUILD_ROOT}/usr/share/doc/graphviz-2.34.0


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
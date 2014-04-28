%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Inkscape is a what you see is what you get Scalable Vector Graphics editor. It is useful for creating, viewing and changing SVG images. 
Name:       inkscape
Version:    0.48.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  boost
Requires:  gc
Requires:  gsl
Requires:  gtkmm
Requires:  little-cms
Source0:    http://downloads.sourceforge.net/inkscape/inkscape-0.48.4.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/inkscape-0.48.4-gc-1.patch
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/inkscape-0.48.4-freetype-1.patch
URL:        http://downloads.sourceforge.net/inkscape
%description
 Inkscape is a what you see is what you get Scalable Vector Graphics editor. It is useful for creating, viewing and changing SVG images. 
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
patch -Np1 -i %_sourcedir/inkscape-0.48.4-gc-1.patch                                    &&
patch -Np1 -i %_sourcedir/inkscape-0.48.4-freetype-1.patch                              &&
sed -e "s@commands_toolbox,@commands_toolbox@" -i src/widgets/desktop-widget.h &&
./configure --prefix=/usr                                                      &&
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
gtk-update-icon-cache &&

update-desktop-database
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
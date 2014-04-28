%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     paps is a text to PostScript converter that works through Pango. Its input is a UTF-8 encoded text file and it outputs vectorized PostScript. It may be used for printing any complex script supported by Pango. 
Name:       paps
Version:    0.6.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  pango
Source0:    http://downloads.sourceforge.net/paps/paps-0.6.8.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/paps-0.6.8-freetype_fix-1.patch
URL:        http://downloads.sourceforge.net/paps
%description
 paps is a text to PostScript converter that works through Pango. Its input is a UTF-8 encoded text file and it outputs vectorized PostScript. It may be used for printing any complex script supported by Pango. 
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
patch -Np1 -i %_sourcedir/paps-0.6.8-freetype_fix-1.patch &&
./configure --prefix=/usr --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d                 ${RPM_BUILD_ROOT}/usr/share/doc/paps-0.6.8 &&

install -v -m644 doxygen-doc/html/* ${RPM_BUILD_ROOT}/usr/share/doc/paps-0.6.8


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
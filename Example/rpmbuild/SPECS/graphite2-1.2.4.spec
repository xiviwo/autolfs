%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Graphite2 is a rendering engine for graphite fonts. These are TrueType fonts with additional tables containing smart rendering information and were originally developed to support complex non-Roman writing systems. They may contain rules for e.g. ligatures, glyph substitution, kerning, justification - this can make them useful even on text written in Roman writing systems such as English. Note that firefox provides an internal copy of the graphite engine and cannot use a system version, but it too should benefit from the availability of graphite fonts. 
Name:       graphite2
Version:    1.2.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Source0:    http://downloads.sourceforge.net/silgraphite/graphite2-1.2.4.tgz
URL:        http://downloads.sourceforge.net/silgraphite
%description
 Graphite2 is a rendering engine for graphite fonts. These are TrueType fonts with additional tables containing smart rendering information and were originally developed to support complex non-Roman writing systems. They may contain rules for e.g. ligatures, glyph substitution, kerning, justification - this can make them useful even on text written in Roman writing systems such as English. Note that firefox provides an internal copy of the graphite engine and cannot use a system version, but it too should benefit from the availability of graphite fonts. 
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
mkdir -pv build &&
cd build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build &&


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Doxygen package contains a documentation system for C++, C, Java, Objective-C, Corba IDL and to some extent PHP, C# and D. It is useful for generating HTML documentation and/or an off-line reference manual from a set of documented source files. There is also support for generating output in RTF, PostScript, hyperlinked PDF, compressed HTML, and Unix man pages. The documentation is extracted directly from the sources, which makes it much easier to keep the documentation consistent with the source code. 
Name:       doxygen
Version:    1.8.5
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.stack.nl/pub/doxygen/doxygen-1.8.5.src.tar.gz
Source1:    ftp://ftp.stack.nl/pub/doxygen/doxygen-1.8.5.src.tar.gz
URL:        http://ftp.stack.nl/pub/doxygen
%description
 The Doxygen package contains a documentation system for C++, C, Java, Objective-C, Corba IDL and to some extent PHP, C# and D. It is useful for generating HTML documentation and/or an off-line reference manual from a set of documented source files. There is also support for generating output in RTF, PostScript, hyperlinked PDF, compressed HTML, and Unix man pages. The documentation is extracted directly from the sources, which makes it much easier to keep the documentation consistent with the source code. 
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
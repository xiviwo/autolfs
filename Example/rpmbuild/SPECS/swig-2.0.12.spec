%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     SWIG (Simplified Wrapper and Interface Generator) is a compiler that integrates C and C++ with languages including Perl, Python, Tcl, Ruby, PHP, Java, C#, D, Go, Lua, Octave, R, Scheme, Ocaml, Modula-3, Common Lisp, and Pike. SWIG can also export its parse tree into Lisp s-expressions and XML. 
Name:       swig
Version:    2.0.12
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  pcre
Source0:    http://downloads.sourceforge.net/swig/swig-2.0.12.tar.gz
URL:        http://downloads.sourceforge.net/swig
%description
 SWIG (Simplified Wrapper and Interface Generator) is a compiler that integrates C and C++ with languages including Perl, Python, Tcl, Ruby, PHP, Java, C#, D, Go, Lua, Octave, R, Scheme, Ocaml, Modula-3, Common Lisp, and Pike. SWIG can also export its parse tree into Lisp s-expressions and XML. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/swig-2.0.12 &&

cp -v -R Doc/* ${RPM_BUILD_ROOT}/usr/share/doc/swig-2.0.12


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
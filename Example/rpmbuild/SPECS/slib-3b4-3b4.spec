%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The SLIB package is a portable library for the Scheme programming language. It provides a platform independent framework for using “packages” of Scheme procedures and syntax. Its catalog can be transparently extended to accommodate packages specific to a site, implementation, user or directory. SLIB provides compatibility and utility functions for all standard Scheme implementations including Bigloo, Chez, ELK 3.0, GAMBIT 3.0, Guile, JScheme, MacScheme, MITScheme, PLT Scheme (DrScheme and MzScheme), Pocket Scheme, RScheme, scheme->C, Scheme48, SCM, SCM Mac, scsh, Stk, T3.1, umb-scheme, and VSCM. 
Name:       slib-3b4
Version:    3b4
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  guile
Source0:    http://groups.csail.mit.edu/mac/ftpdir/scm/slib-3b4.tar.gz
URL:        http://groups.csail.mit.edu/mac/ftpdir/scm
%description
 The SLIB package is a portable library for the Scheme programming language. It provides a platform independent framework for using “packages” of Scheme procedures and syntax. Its catalog can be transparently extended to accommodate packages specific to a site, implementation, user or directory. SLIB provides compatibility and utility functions for all standard Scheme implementations including Bigloo, Chez, ELK 3.0, GAMBIT 3.0, Guile, JScheme, MacScheme, MITScheme, PLT Scheme (DrScheme and MzScheme), Pocket Scheme, RScheme, scheme->C, Scheme48, SCM, SCM Mac, scsh, Stk, T3.1, umb-scheme, and VSCM. 
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
sed -i 's|usr/lib|usr/share|' RScheme.init                      
./configure --prefix=/usr --libdir=/usr/share                   
sed -i -e 's# scm$# guile#;s#ginstall-info#install-info#' -e 's/no-split -o/no-split --force -o/' Makefile         
makeinfo -o slib.txt --plaintext --force slib.texi              
makeinfo -o slib.html --html --no-split --force slib.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/guile/site
make install                                             DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf  %_sourcedir/slib ${RPM_BUILD_ROOT}/usr/share/guile                      

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/guile/site/2.0                     

guile -c "(use-modules (ice-9 slib)) (require 'printf)" 
install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/slib-3b4             

install -v -m644 ANNOUNCE FAQ README slib.{txt,html} ${RPM_BUILD_ROOT}/usr/share/doc/slib-3b4


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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Perl module packages add useful objects to the Perl language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page should be accomplished by installing the dependencies in the order listed. The Perl Module standard build and installation instructions are shown at the bottom of this page. 
Name:       html-parser
Version:    3.71
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  html-tagset
Requires:  libwww-perl
Source0:    http://www.cpan.org/authors/id/G/GA/GAAS/HTML-Parser-3.71.tar.gz
URL:        http://www.cpan.org/authors/id/G/GA/GAAS
%description
 The Perl module packages add useful objects to the Perl language. Modules utilized by packages throughout BLFS are listed here, along with their dependencies. Installation of the modules shown on this page should be accomplished by installing the dependencies in the order listed. The Perl Module standard build and installation instructions are shown at the bottom of this page. 
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


perl Makefile.PL && make && make install DESTDIR=${RPM_BUILD_ROOT} 


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
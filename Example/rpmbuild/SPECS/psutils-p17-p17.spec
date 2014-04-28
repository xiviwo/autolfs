%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     PSUtils is a set of utilities to manipulate PostScript files. 
Name:       psutils-p17
Version:    p17
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.knackered.org/pub/psutils/psutils-p17.tar.gz
URL:        ftp://ftp.knackered.org/pub/psutils
%description
 PSUtils is a set of utilities to manipulate PostScript files. 
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
sed 's@/usr/local@/usr@g' Makefile.unix > Makefile &&
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
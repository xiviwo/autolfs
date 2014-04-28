%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libatomic_ops provides implementations for atomic memory update operations on a number of architectures. This allows direct use of these in reasonably portable code. Unlike earlier similar packages, this one explicitly considers memory barrier semantics, and allows the construction of code that involves minimum overhead across a variety of architectures. 
Name:       libatomic-ops
Version:    7.2e
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.hpl.hp.com/research/linux/atomic_ops/download/libatomic_ops-7.2e.tar.gz
URL:        http://www.hpl.hp.com/research/linux/atomic_ops/download
%description
 libatomic_ops provides implementations for atomic memory update operations on a number of architectures. This allows direct use of these in reasonably portable code. Unlike earlier similar packages, this one explicitly considers memory barrier semantics, and allows the construction of code that involves minimum overhead across a variety of architectures. 
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
sed -i 's#AM_CONFIG_HEADER#AC_CONFIG_HEADERS#' configure.ac &&
sed -i 's#AC_PROG_RANLIB#AC_LIBTOOL_DLOPEN\nAC_PROG_LIBTOOL#' configure.ac &&
sed -i 's#b_L#b_LTL#;s#\.a#.la#g;s#_a_#_la_#' src/Makefile.am &&
sed -i 's#\.a#.so#g;s#\.\./src/#../src/.libs/#g' tests/Makefile.am &&
sed -i 's#pkgdata#doc#' doc/Makefile.am &&
autoreconf -fi &&
./configure --prefix=/usr --docdir=/usr/share/doc/libatomic_ops-7.2e --disable-static &&
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
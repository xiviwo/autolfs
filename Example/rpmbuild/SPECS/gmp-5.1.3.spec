%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GMP package contains math libraries. These have useful functions for arbitrary precision arithmetic. 
Name:       gmp
Version:    5.1.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/gmp/gmp-5.1.3.tar.xz

URL:        http://ftp.gnu.org/gnu/gmp
%description
 The GMP package contains math libraries. These have useful functions for arbitrary precision arithmetic. 
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
ABI=64 
	./configure --prefix=/usr --enable-cxx
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gmp-5.1.3
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gmp-5.1.3

cp    -v doc/{isa_abi_headache,configuration} doc/*.html ${RPM_BUILD_ROOT}/usr/share/doc/gmp-5.1.3


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
%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Bc package contains an arbitrary precision numeric processing language. 
Name:       bc
Version:    1.06.95
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://alpha.gnu.org/gnu/bc/bc-1.06.95.tar.bz2

URL:        http://alpha.gnu.org/gnu/bc
%description
 The Bc package contains an arbitrary precision numeric processing language. 
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
./configure --prefix=/usr --with-readline --mandir=/usr/share/man --infodir=/usr/share/info
make %{?_smp_mflags} 
echo "quit" | ./bc/bc -l Test/checklib.b

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
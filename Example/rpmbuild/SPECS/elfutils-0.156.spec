%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The elfutils package contains set of utilities and libraries for handling ELF (Executable and Linkable Format) files. 
Name:       elfutils
Version:    0.156
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    https://fedorahosted.org/releases/e/l/elfutils/0.156/elfutils-0.156.tar.bz2
URL:        https://fedorahosted.org/releases/e/l/elfutils/0.156
%description
 The elfutils package contains set of utilities and libraries for handling ELF (Executable and Linkable Format) files. 
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
./configure --prefix=/usr --program-prefix="eu-" 
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
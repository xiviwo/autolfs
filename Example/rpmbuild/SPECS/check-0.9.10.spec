%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Check is a unit testing framework for C. It was installed by LFS in the temporary /tools directory. These instructions install it permanently. 
Name:       check
Version:    0.9.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sourceforge.net/projects/check/files/check/0.9.10/check-0.9.10.tar.gz

URL:        http://sourceforge.net/projects/check/files/check/0.9.10
%description
 Check is a unit testing framework for C. It was installed by LFS in the temporary /tools directory. These instructions install it permanently. 
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
./configure --prefix=/usr --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docdir=${RPM_BUILD_ROOT}/usr/share/doc/check-0.9.10 install DESTDIR=${RPM_BUILD_ROOT} 


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
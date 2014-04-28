%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libisoburn is a frontend for libraries libburn and libisofs which enables creation and expansion of ISO-9660 filesystems on all CD/DVD/BD media supported by libburn. This includes media like DVD+RW, which do not support multi-session management on media level and even plain disk files or block devices. 
Name:       libisoburn
Version:    1.3.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libburn
Requires:  libisofs
Source0:    http://files.libburnia-project.org/releases/libisoburn-1.3.2.tar.gz
URL:        http://files.libburnia-project.org/releases
%description
 libisoburn is a frontend for libraries libburn and libisofs which enables creation and expansion of ISO-9660 filesystems on all CD/DVD/BD media supported by libburn. This includes media like DVD+RW, which do not support multi-session management on media level and even plain disk files or block devices. 
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
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     SimpleBurn is a minimalistic application for burning and extracting CDs and DVDs. 
Name:       simpleburn
Version:    1.6.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  gtk
Requires:  libisoburn
Requires:  cdparanoia-iii
Requires:  cdrdao
Source0:    http://simpleburn.tuxfamily.org/IMG/bz2/simpleburn-1.6.5.tar.bz2
URL:        http://simpleburn.tuxfamily.org/IMG/bz2
%description
 SimpleBurn is a minimalistic application for burning and extracting CDs and DVDs. 
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
mkdir -pv build &&
cd build &&
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBURNING=LIBBURNIA .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd build &&


make install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
usermod -a -G cdrom mao
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
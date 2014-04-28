%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Bluefish is a GTK+ text editor targeted towards programmers and web designers, with many options to write websites, scripts and programming code. Bluefish supports many programming and markup languages, and it focuses on editing dynamic and interactive websites. 
Name:       bluefish
Version:    2.2.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Source0:    http://www.bennewitz.com/bluefish/stable/source/bluefish-2.2.5.tar.bz2
URL:        http://www.bennewitz.com/bluefish/stable/source
%description
 Bluefish is a GTK+ text editor targeted towards programmers and web designers, with many options to write websites, scripts and programming code. Bluefish supports many programming and markup languages, and it focuses on editing dynamic and interactive websites. 
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
./configure --prefix=/usr &&
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
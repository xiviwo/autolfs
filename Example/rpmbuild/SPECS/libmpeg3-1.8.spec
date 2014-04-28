%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libMPEG3 supports advanced editing and manipulation of MPEG streams. 
Name:       libmpeg3
Version:    1.8
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  liba52
Requires:  nasm
Source0:    http://downloads.sourceforge.net/heroines/libmpeg3-1.8-src.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/libmpeg3-1.8-makefile_fixes-2.patch
URL:        http://downloads.sourceforge.net/heroines
%description
 libMPEG3 supports advanced editing and manipulation of MPEG streams. 
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
patch -Np1 -i %_sourcedir/libmpeg3-1.8-makefile_fixes-2.patch 
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
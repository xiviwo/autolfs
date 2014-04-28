%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The UnZip package contains ZIP extraction utilities. These are useful for extracting files from ZIP archives. ZIP archives are created with PKZIP or Info-ZIP utilities, primarily in a DOS environment. 
Name:       unzip
Version:    6.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/infozip/unzip60.tar.gz
URL:        http://downloads.sourceforge.net/infozip
%description
 The UnZip package contains ZIP extraction utilities. These are useful for extracting files from ZIP archives. ZIP archives are created with PKZIP or Info-ZIP utilities, primarily in a DOS environment. 
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
case `uname -m` in
  i?86)
    sed -i -e 's/DASM_CRC"/DASM_CRC -DNO_LCHMOD"/' unix/Makefile
make -f unix/Makefile linux %{?_smp_mflags} 

    ;;
  *)
    sed -i -e 's/CFLAGS="-O -Wall/& -DNO_LCHMOD/' unix/Makefile
make -f unix/Makefile linux_noasm %{?_smp_mflags} 

    ;;
esac

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make prefix=${RPM_BUILD_ROOT}/usr MANDIR=${RPM_BUILD_ROOT}/usr/share/man/man1 install DESTDIR=${RPM_BUILD_ROOT} 


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
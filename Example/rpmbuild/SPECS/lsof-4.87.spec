%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The lsof package is useful to LiSt Open Files for a given running application or process. 
Name:       lsof
Version:    4.87
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libtirpc
Source0:    ftp://sunsite.ualberta.ca/pub/Mirror/lsof/lsof_4.87.tar.bz2
URL:        ftp://sunsite.ualberta.ca/pub/Mirror/lsof
%description
 The lsof package is useful to LiSt Open Files for a given running application or process. 
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man8
tar -xf lsof_4.87_src.tar  &&
cd lsof_4.87_src           &&
./Configure -n linux       &&
make CFGL="-L./lib -ltirpc"
install -v lsof.8 ${RPM_BUILD_ROOT}/usr/share/man/man8


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
install -v -m0755 -o root -g root lsof /usr/bin &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
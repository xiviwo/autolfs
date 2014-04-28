%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The UnRar package contains a RAR extraction utility used for extracting files from RAR archives. RAR archives are usually created with WinRAR, primarily in a Windows environment. 
Name:       unrar
Version:    5.0.11
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.rarlab.com/rar/unrarsrc-5.0.11.tar.gz
URL:        http://www.rarlab.com/rar
%description
 The UnRar package contains a RAR extraction utility used for extracting files from RAR archives. RAR archives are usually created with WinRAR, primarily in a Windows environment. 
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
make -f makefile
install -v -m755 unrar ${RPM_BUILD_ROOT}/usr/bin


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
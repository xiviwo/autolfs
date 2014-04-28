%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Desktop File Utils package contains command line utilities for working with Desktop entries. These utilities are used by Desktop Environments and other applications to manipulate the MIME-types application databases and help adhere to the Desktop Entry Specification. 
Name:       desktop-file-utils
Version:    0.22
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Source0:    http://freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.22.tar.xz
URL:        http://freedesktop.org/software/desktop-file-utils/releases
%description
 The Desktop File Utils package contains command line utilities for working with Desktop entries. These utilities are used by Desktop Environments and other applications to manipulate the MIME-types application databases and help adhere to the Desktop Entry Specification. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
make install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
update-desktop-database /usr/share/applications
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
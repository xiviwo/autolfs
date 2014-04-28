%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The cifs-utils provides a means for mounting SMB/CIFS shares on a Linux system. 
Name:       cifs-utils
Version:    6.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.samba.org/pub/linux-cifs/cifs-utils/cifs-utils-6.1.tar.bz2
URL:        ftp://ftp.samba.org/pub/linux-cifs/cifs-utils
%description
 The cifs-utils provides a means for mounting SMB/CIFS shares on a Linux system. 
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
./configure --prefix=/usr 
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
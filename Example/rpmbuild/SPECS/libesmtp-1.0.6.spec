%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libESMTP package contains the libESMTP libraries which are used by some programs to manage email submission to a mail transport layer. 
Name:       libesmtp
Version:    1.0.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.stafford.uklinux.net/libesmtp/libesmtp-1.0.6.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libesmtp-1.0.6.tar.bz2
URL:        http://www.stafford.uklinux.net/libesmtp
%description
 The libESMTP package contains the libESMTP libraries which are used by some programs to manage email submission to a mail transport layer. 
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
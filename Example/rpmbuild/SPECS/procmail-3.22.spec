%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Procmail package contains an autonomous mail processor. This is useful for filtering and sorting incoming mail. 
Name:       procmail
Version:    3.22
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.ring.gr.jp/archives/net/mail/procmail/procmail-3.22.tar.gz
Source1:    ftp://ftp.ucsb.edu/pub/mirrors/procmail/procmail-3.22.tar.gz
URL:        http://www.ring.gr.jp/archives/net/mail/procmail
%description
 The Procmail package contains an autonomous mail processor. This is useful for filtering and sorting incoming mail. 
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


sed -i 's/getline/get_line/' src/*.[ch] &&
make LOCKINGTEST=${RPM_BUILD_ROOT}/tmp install && DESTDIR=${RPM_BUILD_ROOT} 

make install-suid DESTDIR=${RPM_BUILD_ROOT} 


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
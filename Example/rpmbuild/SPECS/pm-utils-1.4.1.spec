%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Power Management Utilities is a small collection of scripts to suspend and hibernate computer that can be used to run user supplied scripts on suspend and resume. 
Name:       pm-utils
Version:    1.4.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://pm-utils.freedesktop.org/releases/pm-utils-1.4.1.tar.gz
URL:        http://pm-utils.freedesktop.org/releases
%description
 The Power Management Utilities is a small collection of scripts to suspend and hibernate computer that can be used to run user supplied scripts on suspend and resume. 
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
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/pm-utils-1.4.1 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man8
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 man/*.1 ${RPM_BUILD_ROOT}/usr/share/man/man1 &&

install -v -m644 man/*.8 ${RPM_BUILD_ROOT}/usr/share/man/man8 &&

ln -svf pm-action.8 ${RPM_BUILD_ROOT}/usr/share/man/man8/pm-suspend.8 &&

ln -svf pm-action.8 ${RPM_BUILD_ROOT}/usr/share/man/man8/pm-hibernate.8 &&

ln -svf pm-action.8 ${RPM_BUILD_ROOT}/usr/share/man/man8/pm-suspend-hybrid.8


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
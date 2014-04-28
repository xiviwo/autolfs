%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The lsb_release script gives information about the Linux Standards Base (LSB) status of the distribution. 
Name:       lsb-release
Version:    1.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sourceforge.net/projects/lsb/files/lsb_release/1.4/lsb-release-1.4.tar.gz
URL:        http://sourceforge.net/projects/lsb/files/lsb_release/1.4
%description
 The lsb_release script gives information about the Linux Standards Base (LSB) status of the distribution. 
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
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
sed -i "s|n/a|unavailable|" lsb_release
./help2man -N --include ./lsb_release.examples --alt_version_key=program_version ./lsb_release > lsb_release.1
install -v -m 644 lsb_release.1 ${RPM_BUILD_ROOT}/usr/share/man/man1/lsb_release.1 &&

install -v -m 755 lsb_release ${RPM_BUILD_ROOT}/usr/bin/lsb_release


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
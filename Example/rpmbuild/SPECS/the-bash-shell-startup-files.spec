%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    the-bash-shell-startup-files
Name:       the-bash-shell-startup-files
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/chapter07/profile.html
%description
the-bash-shell-startup-files
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

mkdir -pv ${RPM_BUILD_ROOT}/etc
cat > /etc/profile << "EOF"
# Begin /etc/profile
export LANG=en_US.utf8
# End /etc/profile
EOF

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
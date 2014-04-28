%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    customizing-the-etc-hosts-file
Name:       customizing-the-etc-hosts-file
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/chapter07/hosts.html
%description
customizing-the-etc-hosts-file
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
cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)
127.0.0.1 localhost
<192.168.1.1> <HOSTNAME.example.org> [alias1] [alias2 ...]
# End /etc/hosts (network card version)
EOF
cat > /etc/hosts << "EOF"
# Begin /etc/hosts (no network card version)
127.0.0.1 localhost
192.168.122.13 alfs
# End /etc/hosts (no network card version)
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
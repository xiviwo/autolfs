%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    configuring-the-linux-console
Name:       configuring-the-linux-console
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/chapter07/console.html
%description
configuring-the-linux-console
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

mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
KEYMAP="pl2"
FONT="lat2a-16 -m 8859-2"
# End /etc/sysconfig/console
EOF
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
KEYMAP="us"

FONT="lat0-16 -m 8859-15"
# End /etc/sysconfig/console
EOF
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="LatArCyrHeb-16"
# End /etc/sysconfig/console
EOF
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
UNICODE="1"
KEYMAP="bg_bds-utf8"
FONT="cyr-sun16"
# End /etc/sysconfig/console
EOF
cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
UNICODE="1"
KEYMAP="us"



# End /etc/sysconfig/console
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
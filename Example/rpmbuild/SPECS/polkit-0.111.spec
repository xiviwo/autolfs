%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Polkit is a toolkit for defining and handling authorizations. It is used for allowing unprivileged processes to communicate with privileged processes. 
Name:       polkit
Version:    0.111
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  intltool
Requires:  js
Source0:    http://www.freedesktop.org/software/polkit/releases/polkit-0.111.tar.gz
URL:        http://www.freedesktop.org/software/polkit/releases
%description
 Polkit is a toolkit for defining and handling authorizations. It is used for allowing unprivileged processes to communicate with privileged processes. 
%pre
groupadd -fg 27 polkitd

useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 -g polkitd -s /bin/false polkitd
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-authfw=shadow --disable-static --libexecdir=/usr/lib/polkit-1 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1
auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session
# End /etc/pam.d/polkit-1
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
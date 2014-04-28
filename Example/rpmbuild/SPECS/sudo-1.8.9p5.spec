%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Sudo package allows a system administrator to give certain users (or groups of users) the ability to run some (or all) commands as root or another user while logging the commands and arguments. 
Name:       sudo
Version:    1.8.9p5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.sudo.ws/sudo/dist/sudo-1.8.9p5.tar.gz
Source1:    ftp://ftp.sudo.ws/pub/sudo/sudo-1.8.9p5.tar.gz
URL:        http://www.sudo.ws/sudo/dist
%description
 The Sudo package allows a system administrator to give certain users (or groups of users) the ability to run some (or all) commands as root or another user while logging the commands and arguments. 
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
./configure --prefix=/usr --libexecdir=/usr/lib/sudo --docdir=/usr/share/doc/sudo-1.8.9p5 --with-timedir=/var/lib/sudo --with-all-insults --with-env-editor --with-passprompt="[sudo] password for %p" &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/pam.d/sudo << "EOF"
# Begin /etc/pam.d/sudo
# include the default auth settings
auth      include     system-auth
# include the default account settings
account   include     system-account
# Set default environment variables for the service user
session   required    pam_env.so
# include system session defaults
session   include     system-session
# End /etc/pam.d/sudo
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod 644 /etc/pam.d/sudo
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
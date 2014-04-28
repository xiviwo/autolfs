%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ssh-askpass is a generic executable name for many packages, with similar names, that provide a interactive X service to grab password for packages requiring administrative privileges to be run. It prompts the user with a window box where the necessary password can be inserted. Here, we choose Damien Miller's package distributed in the OpenSSH tarball. 
Name:       ssh-askpass
Version:    6.5p1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  sudo
Requires:  xorg-libraries
Requires:  x-window-system-environment
Source0:    http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
Source1:    ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
URL:        http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable
%description
 The ssh-askpass is a generic executable name for many packages, with similar names, that provide a interactive X service to grab password for packages requiring administrative privileges to be run. It prompts the user with a window box where the necessary password can be inserted. Here, we choose Damien Miller's package distributed in the OpenSSH tarball. 
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

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/openssh
mkdir -pv ${RPM_BUILD_ROOT}/etc
cd contrib &&
make gnome-ssh-askpass2
install -v -d -m755                  ${RPM_BUILD_ROOT}/usr/lib/openssh/contrib     &&

install -v -m755  gnome-ssh-askpass2 ${RPM_BUILD_ROOT}/usr/lib/openssh/contrib     &&

ln -svf -f contrib/gnome-ssh-askpass2 ${RPM_BUILD_ROOT}/usr/lib/openssh/ssh-askpass


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/sudo.conf << "EOF" &&

# Path to askpass helper program

Path askpass /usr/lib/openssh/ssh-askpass

EOF

chmod -v 0644 /etc/sudo.conf
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
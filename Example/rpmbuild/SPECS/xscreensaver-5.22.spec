%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The XScreenSaver is a modular screen saver and locker for the X Window System. It is highly customizable and allows the use of any program that can draw on the root window as a display mode. The purpose of XScreenSaver is to display pretty pictures on your screen when it is not in use, in keeping with the philosophy that unattended monitors should always be doing something interesting, just like they do in the movies. However, XScreenSaver can also be used as a screen locker, to prevent others from using your terminal while you are away. 
Name:       xscreensaver
Version:    5.22
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  bc
Requires:  libglade
Requires:  xorg-applications
Source0:    http://www.jwz.org/xscreensaver/xscreensaver-5.22.tar.gz
URL:        http://www.jwz.org/xscreensaver
%description
 The XScreenSaver is a modular screen saver and locker for the X Window System. It is highly customizable and allows the use of any program that can draw on the root window as a display mode. The purpose of XScreenSaver is to display pretty pictures on your screen when it is not in use, in keeping with the philosophy that unattended monitors should always be doing something interesting, just like they do in the movies. However, XScreenSaver can also be used as a screen locker, to prevent others from using your terminal while you are away. 
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
./configure --prefix=/usr --libexecdir=/usr/lib 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/pam.d/xscreensaver << "EOF"
# Begin /etc/pam.d/xscreensaver
auth    include system-auth
account include system-account
# End /etc/pam.d/xscreensaver
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
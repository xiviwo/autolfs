%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Xorg Server is the core of the X Window system. 
Name:       xorg-server
Version:    1.14.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Requires:  pixman
Requires:  xorg-fonts
Requires:  xkeyboardconfig
Source0:    http://xorg.freedesktop.org/archive/individual/xserver/xorg-server-1.14.3.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/xserver/xorg-server-1.14.3.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/xorg-server-1.14.3-add_prime_support-1.patch
URL:        http://xorg.freedesktop.org/archive/individual/xserver
%description
 The Xorg Server is the core of the X Window system. 
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
patch -Np1 -i %_sourcedir/xorg-server-1.14.3-add_prime_support-1.patch

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/X11/xorg.conf.d
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
./configure $XORG_CONFIG --with-xkb-output=${RPM_BUILD_ROOT}/var/lib/xkb --enable-install-setuid 
make
make install  DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/etc/X11/xorg.conf.d 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/sysconfig/createfiles << "EOF"

/tmp/.ICE-unix dir 1777 root root

/tmp/.X11-unix dir 1777 root root

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
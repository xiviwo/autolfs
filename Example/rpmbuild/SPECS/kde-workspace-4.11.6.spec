%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Kde-workspace package contains components that are central to providing the KDE desktop environment. Of particular importance are KWin, the KDE window manager, and Plasma, which provides the workspace interface. 
Name:       kde-workspace
Version:    4.11.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  kactivities
Requires:  qimageblitz
Requires:  xcb-util-image
Requires:  xcb-util-renderutil
Requires:  xcb-util-keysyms
Requires:  xcb-util-wm
Requires:  kdepimlibs
Requires:  nepomuk-core
Requires:  boost
Requires:  freetype
Requires:  pciutils
Requires:  consolekit
Source0:    http://download.kde.org/stable/4.12.2/src/kde-workspace-4.11.6.tar.xz
Source1:    ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/kde-workspace-4.11.6.tar.xz
URL:        http://download.kde.org/stable/4.12.2/src
%description
 The Kde-workspace package contains components that are central to providing the KDE desktop environment. Of particular importance are KWin, the KDE window manager, and Plasma, which provides the workspace interface. 
%pre
groupadd -g 37 kdm  || :

useradd -c "KDM Daemon Owner" -d /var/lib/kdm -g kdm -u 37 -s /bin/false kdm  || :

install -o kdm -g kdm -dm755 /var/lib/kdm
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
mkdir -pv build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -DINSTALL_PYTHON_FILES_IN_PYTHON_PREFIX=TRUE -Wno-dev .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/xsessions
make install                  && DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/xsessions &&

ln -sf $KDE_PREFIX/share/apps/kdm/sessions/kde-plasma.desktop ${RPM_BUILD_ROOT}/usr/share/xsessions/kde-plasma.desktop

cat > /etc/pam.d/kde-np << "EOF" &&
# Begin /etc/pam.d/kde-np
auth     requisite      pam_nologin.so
auth     required       pam_env.so
auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so
account  include        system-account
password include        system-password
session  include        system-session
# End /etc/pam.d/kde-np
EOF
cat > /etc/pam.d/kscreensaver << "EOF"
# Begin /etc/pam.d/kscreensaver
auth    include system-auth
account include system-account
# End /etc/pam.d/kscreensaver
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/pam.d/kde << "EOF" &&

# Begin /etc/pam.d/kde

auth     requisite      pam_nologin.so

auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet

auth     include        system-auth

account  include        system-account

password include        system-password

session  include        system-session

# End /etc/pam.d/kde

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
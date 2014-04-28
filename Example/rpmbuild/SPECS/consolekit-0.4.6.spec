%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ConsoleKit package is a framework for keeping track of the various users, sessions, and seats present on a system. It provides a mechanism for software to react to changes of any of these items or of any of the metadata associated with them. 
Name:       consolekit
Version:    0.4.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  acl
Requires:  dbus-glib
Requires:  xorg-libraries
Requires:  linux-pam
Requires:  polkit
Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/c/ConsoleKit-0.4.6.tar.xz
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/c
%description
 The ConsoleKit package is a framework for keeping track of the various users, sessions, and seats present on a system. It provides a mechanism for software to react to changes of any of these items or of any of the metadata associated with them. 
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-udev-acl --enable-pam-module  &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc/pam.d
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/ConsoleKit/run-session.d
make install DESTDIR=${RPM_BUILD_ROOT} 

cat > /usr/lib/ConsoleKit/run-session.d/pam-foreground-compat.ck << "EOF"
#!/bin/sh
TAGDIR=/var/run/console
[ -n "$CK_SESSION_USER_UID" ] || exit 1
[ "$CK_SESSION_IS_LOCAL" = "true" ] || exit 0
TAGFILE="$TAGDIR/`getent passwd $CK_SESSION_USER_UID | cut -f 1 -d:`"
if [ "$1" = "session_added" ]; then
    mkdir -pv -p "$TAGDIR"
    echo "$CK_SESSION_ID" >> "$TAGFILE"
fi
if [ "$1" = "session_removed" ] && [ -e "$TAGFILE" ]; then
    sed -i "\%^$CK_SESSION_ID\$%d" "$TAGFILE"
    [ -s "$TAGFILE" ] || rm -f "$TAGFILE"
fi
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/pam.d/system-session << "EOF"

# Begin ConsoleKit addition

session   optional    pam_loginuid.so

session   optional    pam_ck_connector.so nox11

# End ConsoleKit addition

EOF

chmod -v 755 /usr/lib/ConsoleKit/run-session.d/pam-foreground-compat.ck
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
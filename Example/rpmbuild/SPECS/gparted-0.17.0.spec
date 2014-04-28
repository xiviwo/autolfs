%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Gparted is the Gnome Partition Editor, a Gtk 2 GUI for other command line tools that can create, reorganise or delete disk partitions. 
Name:       gparted
Version:    0.17.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gtkmm
Requires:  intltool
Requires:  parted
Source0:    http://downloads.sourceforge.net/gparted/gparted-0.17.0.tar.bz2
URL:        http://downloads.sourceforge.net/gparted
%description
 Gparted is the Gnome Partition Editor, a Gtk 2 GUI for other command line tools that can create, reorganise or delete disk partitions. 
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
./configure --prefix=/usr --disable-doc --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/polkit-1/actions
mkdir -pv ${RPM_BUILD_ROOT}/usr/sbin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/
make install DESTDIR=${RPM_BUILD_ROOT} 

cp -v ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop.back &&

sed -i 's/Exec=${RPM_BUILD_ROOT}/Exec=sudo -A ${RPM_BUILD_ROOT}/'               ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop      &&

cp -v ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop.back &&

sed -i 's:/usr/sbin/gparted:/usr/sbin/gparted_polkit:' ${RPM_BUILD_ROOT}/usr/share/applications/gparted.desktop      &&

cat > /usr/sbin/gparted_polkit << "EOF" &&
#!/bin/bash
pkexec /usr/sbin/gparted $@
EOF
cat > /usr/share/polkit-1/actions/org.gnome.gparted.policy << "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <action id="org.freedesktop.policykit.pkexec.run-gparted">
    <description>Run GParted</description>
    <message>Authentication is required to run GParted</message>
    <defaults>
      <allow_any>no</allow_any>
      <allow_inactive>no</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/sbin/gparted</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>
</policyconfig>
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 0755 /usr/sbin/gparted_polkit

chmod -v 0644 /usr/share/polkit-1/actions/org.gnome.gparted.policy
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog
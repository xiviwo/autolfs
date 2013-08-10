Name:           creatingessentialfilesandsymlinks
Version:	1.0
Release:        1%{?dist}
Summary:	creatingessentialfilesandsymlinks

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/createfiles.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
CreatingEssentialFilesandSymlinks

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -pv $RPM_BUILD_ROOT/etc
mkdir -pv $RPM_BUILD_ROOT/var/log
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/bin
mkdir -pv $RPM_BUILD_ROOT/usr
ln -sv bash $RPM_BUILD_ROOT/bin/sh
touch $RPM_BUILD_ROOT/etc/mtab
touch $RPM_BUILD_ROOT/var/log/{btmp,lastlog,wtmp}

chgrp -v utmp $RPM_BUILD_ROOT/var/log/lastlog

chmod -v 664  $RPM_BUILD_ROOT/var/log/lastlog

chmod -v 600  $RPM_BUILD_ROOT/var/log/btmp

cat > $RPM_BUILD_ROOT/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > $RPM_BUILD_ROOT/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
mail:x:34:
nogroup:x:99:
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog





Name:           usinggrubtosetupthebootprocess
Version:	1.0
Release:        1%{?dist}
Summary:	usinggrubtosetupthebootprocess

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter08/grub.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
UsingGRUBtoSetUptheBootProcess

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/dev
sudo mount -v --bind /dev $RPM_BUILD_ROOT/dev
mkdir -pv $RPM_BUILD_ROOT/boot/grub

cat > $RPM_BUILD_ROOT/boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,1)

menuentry "GNU/Linux, Linux 3.8.1-lfs-7.3" {
        linux   /boot/vmlinuz-3.8.1-lfs-7.3 root=/dev/sda1 ro
}
EOF

cat > $RPM_BUILD_ROOT/boot/grub/device.map << "EOF"
(hd0)	/dev/sda
(hd1)	/dev/sdb
EOF


%post
grub-install /dev/sdb

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog




Name:           creatingcustomsymlinkstodevices
Version:	
Release:        1%{?dist}
Summary:	

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/symlinks.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
CreatingCustomSymlinkstoDevices

%prep
%setup -q

%build

sed -i -e 's/"write_cd_rules"/"write_cd_rules mode"/' \
    $RPM_BUILD_ROOT/etc/udev/rules.d/83-cdrom-symlinks.rules

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT install
mkdir -pv $RPM_BUILD_ROOT/sys/block
mkdir -pv $RPM_BUILD_ROOT/sys/class/video4linux
udevadm test $RPM_BUILD_ROOT/sys/block/hdd
udevadm info -a -p $RPM_BUILD_ROOT/sys/class/video4linux/video0


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
    SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
    SYMLINK+="tvtuner"

EOF

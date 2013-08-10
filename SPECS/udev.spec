Name:           udev
Version:	197
Release:        1%{?dist}
Summary:	The Udev package contains programs for dynamic creation of device          nodes. The development of udev has been merged with systemd, but          most of systemd is incompatible with LFS. Here we build and install          just the needed udev files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/udev.html
Source0:        http://www.freedesktop.org/software/systemd/systemd-197.tar.xz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Udev package contains programs for dynamic creation of device          nodes. The development of udev has been merged with systemd, but          most of systemd is incompatible with LFS. Here we build and install          just the needed udev files.

%prep
%setup -q -n systemd-197
tar -xvf ../udev-lfs-197-2.tar.bz2
sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh

%build
make -f udev-lfs-197-2/Makefile.lfs %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make -f udev-lfs-197-2/Makefile.lfs install DESTDIR=$RPM_BUILD_ROOT
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
sudo bash udev-lfs-197-2/init-net-rules.sh DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc/udev/rules.d/
sudo mv -v /etc/udev/rules.d/70-persistent-net.rules $RPM_BUILD_ROOT/etc/udev/rules.d/
sed -i 's/\"00:0c:29:[^\\".]*\"/\"00:0c:29:*:*:*\"/' $RPM_BUILD_ROOT/etc/udev/rules.d/70-persistent-net.rules

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog





Name:           generalnetworkconfiguration
Version:	1.0
Release:        1%{?dist}
Summary:	generalnetworkconfiguration

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/network.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
GeneralNetworkConfiguration

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -pv  $RPM_BUILD_ROOT/etc/sysconfig/
cd  $RPM_BUILD_ROOT/etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.136.12
GATEWAY=192.168.136.2
PREFIX=24
BROADCAST=192.168.136.255
EOF

cat >  $RPM_BUILD_ROOT/etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf


nameserver 192.168.136.2
nameserver 192.168.136.1


# End /etc/resolv.conf
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



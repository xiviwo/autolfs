Name:           customizingtheetchostsfile
Version:	1.0
Release:        1%{?dist}
Summary:	customizingtheetchostsfile

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/hosts.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
CustomizingtheetchostsFile

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc
cat > $RPM_BUILD_ROOT/etc/hosts << "EOF"
# Begin /etc/hosts (network card version)

127.0.0.1 localhost
192.168.136.12	alfs

# End /etc/hosts (network card version)
EOF



%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



Name:           configuringthesystemhostname
Version:	1.0
Release:        1%{?dist}
Summary:	configuringthesystemhostname

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/hostname.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
Configuringthesystemhostname

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -pv $RPM_BUILD_ROOT/etc/sysconfig
echo "HOSTNAME=alfs" > $RPM_BUILD_ROOT/etc/sysconfig/network



%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

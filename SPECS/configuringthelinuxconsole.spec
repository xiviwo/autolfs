Name:           configuringthelinuxconsole
Version:	1.0
Release:        1%{?dist}
Summary:	configuringthelinuxconsole

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/console.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
ConfiguringtheLinuxConsole

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc/sysconfig
cat > $RPM_BUILD_ROOT/etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="us"


# End /etc/sysconfig/console
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


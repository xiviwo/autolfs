Name:           configuringthesetclockscript
Version:	1.0
Release:        1%{?dist}
Summary:	configuringthesetclockscript

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/setclock.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
ConfiguringthesetclockScript

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc/sysconfig
cat > $RPM_BUILD_ROOT/etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



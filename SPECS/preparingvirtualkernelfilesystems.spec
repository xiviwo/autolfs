Name:           preparingvirtualkernelfilesystems
Version:	1.0
Release:        1%{?dist}
Summary:	preparingvirtualkernelfilesystems

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kernfs.html
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
PreparingVirtualKernelFileSystems

%prep


%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/{dev,proc,sys}
mknod -m 600 $RPM_BUILD_ROOT/dev/console c 5 1
mknod -m 666 $RPM_BUILD_ROOT/dev/null c 1 3


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


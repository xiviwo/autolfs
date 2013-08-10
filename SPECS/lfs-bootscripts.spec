Name:           lfs-bootscripts
Version:	20130123
Release:        1%{?dist}
Summary:	The LFS-Bootscripts package contains a set of scripts to start/stop          the LFS system at bootup/shutdown.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter07/bootscripts.html
Source0:        http://www.linuxfromscratch.org/lfs/downloads/7.3/lfs-bootscripts-20130123.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The LFS-Bootscripts package contains a set of scripts to start/stop          the LFS system at bootup/shutdown.

%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

Name:           sysvinit
Version:	2.88
Release:        1%{?dist}
Summary:	The Sysvinit package contains programs for controlling the startup,          running, and shutdown of the system.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/sysvinit.html
Source0:        http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.88dsf.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Sysvinit package contains programs for controlling the startup,          running, and shutdown of the system.

%prep
%setup -q -n sysvinit-2.88dsf

%build

sed -i 's@Sending processes@& configured via $RPM_BUILD_ROOT/etc/inittab@g' src/init.c

sed -i -e '/utmpdump/d' \
       -e '/mountpoint/d' src/Makefile
make -C src %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make -C src install ROOT=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

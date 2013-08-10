Name:           util-linux
Version:	2.22.2
Release:        1%{?dist}
Summary:	The Util-linux package contains miscellaneous utility programs.          Among them are utilities for handling file systems, consoles,          partitions, and messages.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/util-linux.html
Source0:        http://www.kernel.org/pub/linux/utils/util-linux/v2.22/util-linux-2.22.2.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Util-linux package contains miscellaneous utility programs.          Among them are utilities for handling file systems, consoles,          partitions, and messages.

%prep
%setup -q

%build

sed -i -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
     $(grep -rl '/etc/adjtime' .)

mkdir -pv $RPM_BUILD_ROOT/var/lib/hwclock

./configure --disable-su --disable-sulogin --disable-login
make %{?_smp_mflags}

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

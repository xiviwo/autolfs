Name:           psmisc
Version:	22.20
Release:        1%{?dist}
Summary:	The Psmisc package contains programs for displaying information          about running processes.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/psmisc.html
Source0:        http://prdownloads.sourceforge.net/psmisc/psmisc-22.20.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Psmisc package contains programs for displaying information          about running processes.

%prep
%setup -q

%build

./configure --prefix=/usr
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/bin
mv -v $RPM_BUILD_ROOT/usr/bin/fuser   $RPM_BUILD_ROOT/bin

mv -v $RPM_BUILD_ROOT/usr/bin/killall $RPM_BUILD_ROOT/bin


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

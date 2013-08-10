Name:           make
Version:	3.82
Release:        1%{?dist}
Summary:	The Make package contains a program for compiling packages.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/make.html
Source0:        http://ftp.gnu.org/gnu/make/make-3.82.tar.bz2

Patch0:        make-3.82-upstream_fixes-3.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Make package contains a program for compiling packages.

%prep
%setup -q
%patch0 -p1 

%build

./configure --prefix=/usr
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


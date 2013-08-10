Name:           automake
Version:	1.13.1
Release:        1%{?dist}
Summary:	The Automake package contains programs for generating Makefiles for          use with Autoconf.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/automake.html
Source0:        http://ftp.gnu.org/gnu/automake/automake-1.13.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Automake package contains programs for generating Makefiles for          use with Autoconf.

%prep
%setup -q

%build

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.13.1
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


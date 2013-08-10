Name:           autoconf
Version:	2.69
Release:        1%{?dist}
Summary:	The Autoconf package contains programs for producing shell scripts          that can automatically configure source code.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/autoconf.html
Source0:        http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Autoconf package contains programs for producing shell scripts          that can automatically configure source code.

%prep
%setup -q

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


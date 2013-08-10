Name:           gawk
Version:	4.0.2
Release:        1%{?dist}
Summary:	The Gawk package contains programs for manipulating text files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gawk.html
Source0:        http://ftp.gnu.org/gnu/gawk/gawk-4.0.2.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Gawk package contains programs for manipulating text files.

%prep
%setup -q

%build

./configure --prefix=/usr --libexecdir=/usr/lib
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


Name:           sed
Version:	4.2.2
Release:        1%{?dist}
Summary:	The Sed package contains a stream editor.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/sed.html
Source0:        http://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Sed package contains a stream editor.

%prep
%setup -q

%build

./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make -C doc install-html DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


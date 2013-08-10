Name:           man-pages
Version:	3.47
Release:        1%{?dist}
Summary:	The Man-pages package contains over 1,900 man pages.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/man-pages.html
Source0:        http://www.kernel.org/pub/linux/docs/man-pages/man-pages-3.47.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Man-pages package contains over 1,900 man pages.

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

Name:           less
Version:	451
Release:        1%{?dist}
Summary:	The Less package contains a text file viewer.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/less.html
Source0:        http://www.greenwoodsoftware.com/less/less-451.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Less package contains a text file viewer.

%prep
%setup -q

%build

./configure --prefix=/usr --sysconfdir=/etc
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

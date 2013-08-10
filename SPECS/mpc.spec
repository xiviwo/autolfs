Name:           mpc
Version:	1.0.1
Release:        1%{?dist}
Summary:	The MPC package contains a library for the arithmetic of complex          numbers with arbitrarily high precision and correct rounding of the          result.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/mpc.html
Source0:        http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The MPC package contains a library for the arithmetic of complex          numbers with arbitrarily high precision and correct rounding of the          result.

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


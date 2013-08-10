Name:           gmp
Version:	5.1.1
Release:        1%{?dist}
Summary:	The GMP package contains math libraries. These have useful          functions for arbitrary precision arithmetic.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gmp.html
Source0:        ftp://ftp.gmplib.org/pub/gmp-5.1.1/gmp-5.1.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The GMP package contains math libraries. These have useful          functions for arbitrary precision arithmetic.

%prep
%setup -q

%build

ABI=32 ./configure --prefix=/usr --enable-cxx

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


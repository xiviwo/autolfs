Name:           mpfr
Version:	3.1.1
Release:        1%{?dist}
Summary:	The MPFR package contains functions for multiple precision math.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/mpfr.html
Source0:        http://www.mpfr.org/mpfr-3.1.1/mpfr-3.1.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The MPFR package contains functions for multiple precision math.

%prep
%setup -q

%build

./configure  --prefix=/usr        \
             --enable-thread-safe \
             --docdir=/usr/share/doc/mpfr-3.1.1
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make install-html DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

Name:           libpipeline
Version:	1.2.2
Release:        1%{?dist}
Summary:	The Libpipeline package contains a library for manipulating          pipelines of subprocesses in a flexible and convenient way.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libpipeline.html
Source0:        http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.2.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Libpipeline package contains a library for manipulating          pipelines of subprocesses in a flexible and convenient way.

%prep
%setup -q

%build

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr
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


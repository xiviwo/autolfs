Name:           file
Version:	5.13
Release:        1%{?dist}
Summary:	The File package contains a utility for determining the type of a          given file or files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html
Source0:        ftp://ftp.astron.com/pub/file/file-5.13.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The File package contains a utility for determining the type of a          given file or files.

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


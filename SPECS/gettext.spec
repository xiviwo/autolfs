Name:           gettext
Version:	0.18.2
Release:        1%{?dist}
Summary:	The Gettext package contains utilities for internationalization and          localization. These allow programs to be compiled with NLS (Native          Language Support), enabling them to output messages in the user's          native language.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gettext.html
Source0:        http://ftp.gnu.org/gnu/gettext/gettext-0.18.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Gettext package contains utilities for internationalization and          localization. These allow programs to be compiled with NLS (Native          Language Support), enabling them to output messages in the user's          native language.

%prep
%setup -q

%build

./configure --prefix=/usr \
            --docdir=/usr/share/doc/gettext-0.18.2
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


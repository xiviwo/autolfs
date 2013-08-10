Name:           libtool
Version:	2.4.2
Release:        1%{?dist}
Summary:	The Libtool package contains the GNU generic library support          script. It wraps the complexity of using shared libraries in a          consistent, portable interface.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/libtool.html
Source0:        http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Libtool package contains the GNU generic library support          script. It wraps the complexity of using shared libraries in a          consistent, portable interface.

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


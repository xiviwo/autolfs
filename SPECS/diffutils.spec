Name:           diffutils
Version:	3.2
Release:        1%{?dist}
Summary:	The Diffutils package contains programs that show the differences          between files or directories.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/diffutils.html
Source0:        http://ftp.gnu.org/gnu/diffutils/diffutils-3.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Diffutils package contains programs that show the differences          between files or directories.

%prep
%setup -q

%build

sed -i -e '/gets is a/d' lib/stdio.in.h

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



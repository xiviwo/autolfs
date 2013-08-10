Name:           bash
Version:	4.2
Release:        1%{?dist}
Summary:	The Bash package contains the Bourne-Again SHell.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/bash.html
Source0:        http://ftp.gnu.org/gnu/bash/bash-4.2.tar.gz

Patch0:        bash-4.2-fixes-11.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Bash package contains the Bourne-Again SHell.

%prep
%setup -q
%patch0 -p1 

%build

./configure --prefix=/usr                     \
            --bindir=/bin                     \
            --htmldir=/usr/share/doc/bash-4.2 \
            --without-bash-malloc             \
            --with-installed-readline
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


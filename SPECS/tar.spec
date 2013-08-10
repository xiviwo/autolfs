Name:           tar
Version:	1.26
Release:        1%{?dist}
Summary:	The Tar package contains an archiving program.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/tar.html
Source0:        http://ftp.gnu.org/gnu/tar/tar-1.26.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Tar package contains an archiving program.

%prep
%setup -q

%build

sed -i -e '/gets is a/d' gnu/stdio.in.h

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin \
            --libexecdir=/usr/sbin
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make -C doc install-html docdir=$RPM_BUILD_ROOT/usr/share/doc/tar-1.26 DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


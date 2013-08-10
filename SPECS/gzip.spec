Name:           gzip
Version:	1.5
Release:        1%{?dist}
Summary:	The Gzip package contains programs for compressing and          decompressing files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html
Source0:        http://ftp.gnu.org/gnu/gzip/gzip-1.5.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Gzip package contains programs for compressing and          decompressing files.

%prep
%setup -q

%build

./configure --prefix=/usr --bindir=/bin
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/bin
mv -v $RPM_BUILD_ROOT/bin/{gzexe,uncompress,zcmp,zdiff,zegrep} $RPM_BUILD_ROOT/usr/bin

mv -v $RPM_BUILD_ROOT/bin/{zfgrep,zforce,zgrep,zless,zmore,znew} $RPM_BUILD_ROOT/usr/bin


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


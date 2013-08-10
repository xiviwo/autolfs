Name:           gdbm
Version:	1.10
Release:        1%{?dist}
Summary:	The GDBM package contains the GNU Database Manager. This is a disk          file format database which stores key/data-pairs in single files.          The actual data of any record being stored is indexed by a unique          key, which can be retrieved in less time than if it was stored in a          text file.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gdbm.html
Source0:        http://ftp.gnu.org/gnu/gdbm/gdbm-1.10.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The GDBM package contains the GNU Database Manager. This is a disk          file format database which stores key/data-pairs in single files.          The actual data of any record being stored is indexed by a unique          key, which can be retrieved in less time than if it was stored in a          text file.

%prep
%setup -q

%build

./configure --prefix=/usr --enable-libgdbm-compat
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


Name:           texinfo
Version:	5.0
Release:        1%{?dist}
Summary:	The Texinfo package contains programs for reading, writing, and          converting info pages.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/texinfo.html
Source0:        http://ftp.gnu.org/gnu/texinfo/texinfo-5.0.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Texinfo package contains programs for reading, writing, and          converting info pages.

%prep
%setup -q

%build

./configure --prefix=/usr
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make TEXMF=$RPM_BUILD_ROOT/usr/share/texmf install-tex DESTDIR=$RPM_BUILD_ROOT
cd $RPM_BUILD_ROOT/usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog




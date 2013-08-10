Name:           xz
Version:	5.0.4
Release:        1%{?dist}
Summary:	The Xz package contains programs for compressing and decompressing          files. It provides capabilities for the lzma and the newer xz          compression formats. Compressing text files withxzyields a better compression          percentage than with the traditionalgziporbzip2commands.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/xz-utils.html
Source0:        http://tukaani.org/xz/xz-5.0.4.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Xz package contains programs for compressing and decompressing          files. It provides capabilities for the lzma and the newer xz          compression formats. Compressing text files withxzyields a better compression          percentage than with the traditionalgziporbzip2commands.

%prep
%setup -q

%build

./configure --prefix=/usr --libdir=/lib --docdir=/usr/share/doc/xz-5.0.4
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make pkgconfigdir=$RPM_BUILD_ROOT/usr/lib/pkgconfig install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



Name:           linux-api-headers
Version:	3.8.1
Release:        1%{?dist}
Summary:	The Linux API Headers (in linux-3.8.1.tar.xz) expose the kernel's          API for use by Glibc.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/linux-headers.html
Source0:        http://www.kernel.org/pub/linux/kernel/v3.x/linux-3.8.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Linux API Headers (in linux-3.8.1.tar.xz) expose the kernel's          API for use by Glibc.

%prep
%setup -q -n linux-3.8.1

%build
make mrproper %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make headers_check
 DESTDIR=$RPM_BUILD_ROOT
make INSTALL_HDR_PATH=dest headers_install
 DESTDIR=$RPM_BUILD_ROOT
find dest/include \( -name .install -o -name ..install.cmd \) -delete
 DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/include
cp -rv dest/include/* $RPM_BUILD_ROOT/usr/include


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

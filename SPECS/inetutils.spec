Name:           inetutils
Version:	1.9.1
Release:        1%{?dist}
Summary:	The Inetutils package contains programs for basic networking.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/inetutils.html
Source0:        http://ftp.gnu.org/gnu/inetutils/inetutils-1.9.1.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Inetutils package contains programs for basic networking.

%prep
%setup -q

%build

sed -i -e '/gets is a/d' lib/stdio.in.h

./configure --prefix=/usr  \
    --libexecdir=/usr/sbin \
    --localstatedir=/var   \
    --disable-ifconfig     \
    --disable-logger       \
    --disable-syslogd      \
    --disable-whois        \
    --disable-servers
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/bin
mv -v $RPM_BUILD_ROOT/usr/bin/{hostname,ping,ping6,traceroute} $RPM_BUILD_ROOT/bin


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


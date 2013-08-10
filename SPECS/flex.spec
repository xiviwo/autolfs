Name:           flex
Version:	2.5.37
Release:        1%{?dist}
Summary:	The Flex package contains a utility for generating programs that          recognize patterns in text.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/flex.html
Source0:        http://prdownloads.sourceforge.net/flex/flex-2.5.37.tar.bz2

Patch0:        flex-2.5.37-bison-2.6.1-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Flex package contains a utility for generating programs that          recognize patterns in text.

%prep
%setup -q
%patch0 -p1 

%build

./configure --prefix=/usr             \
            --docdir=/usr/share/doc/flex-2.5.37
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/usr/bin
ln -sv libfl.a $RPM_BUILD_ROOT/usr/lib/libl.a
cat > $RPM_BUILD_ROOT/usr/bin/lex << "EOF"

#!/bin/sh

# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex

EOF

chmod -v 755 $RPM_BUILD_ROOT/usr/bin/lex



%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


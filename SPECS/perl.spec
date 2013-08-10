Name:           perl
Version:	5.16.2
Release:        1%{?dist}
Summary:	The Perl package contains the Practical Extraction and Report          Language.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/perl.html
Source0:        http://www.cpan.org/src/5.0/perl-5.16.2.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Perl package contains the Practical Extraction and Report          Language.

%prep
%setup -q

%build

sed -i -e "s|BUILD_ZLIB\s*= True|BUILD_ZLIB = False|"           \
       -e "s|INCLUDE\s*= ./zlib-src|INCLUDE    = $RPM_BUILD_ROOT/usr/include|" \
       -e "s|LIB\s*= ./zlib-src|LIB        = $RPM_BUILD_ROOT/usr/lib|"         \
    cpan/Compress-Raw-Zlib/config.in

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc
echo "127.0.0.1 localhost $(hostname)" > $RPM_BUILD_ROOT/etc/hosts


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

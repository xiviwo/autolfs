Name:           kbd
Version:	1.15.5
Release:        1%{?dist}
Summary:	The Kbd package contains key-table files, console fonts, and          keyboard utilities.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kbd.html
Source0:        http://ftp.altlinux.org/pub/people/legion/kbd/kbd-1.15.5.tar.gz

Patch0:        kbd-1.15.5-backspace-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Kbd package contains key-table files, console fonts, and          keyboard utilities.

%prep
%setup -q
%patch0 -p1 

%build

sed -i -e '326 s/if/while/' src/loadkeys.analyze.l

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 $RPM_BUILD_ROOT//' man/man8/Makefile.in

./configure --prefix=/usr --datadir=/lib/kbd \
  --disable-vlock
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
mkdir -pv $RPM_BUILD_ROOT/bin
mv -v $RPM_BUILD_ROOT/usr/bin/{kbd_mode,loadkeys,openvt,setfont} $RPM_BUILD_ROOT/bin



%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

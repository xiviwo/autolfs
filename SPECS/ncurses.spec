Name:           ncurses
Version:	5.9
Release:        1%{?dist}
Summary:	The Ncurses package contains libraries for terminal-independent          handling of character screens.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/ncurses.html
Source0:        ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Ncurses package contains libraries for terminal-independent          handling of character screens.

%prep
%setup -q

%build

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --enable-pc-files       \
            --enable-widec
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mv -v $RPM_BUILD_ROOT/usr/lib/libncursesw.so.5* $RPM_BUILD_ROOT/lib
ln -sfv ../../lib/libncursesw.so.5 $RPM_BUILD_ROOT/usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do

    rm -vf                    $RPM_BUILD_ROOT/usr/lib/lib${lib}.so

    echo "INPUT(-l${lib}w)" > $RPM_BUILD_ROOT/usr/lib/lib${lib}.so

    ln -sfv lib${lib}w.a      $RPM_BUILD_ROOT/usr/lib/lib${lib}.a

    ln -sfv ${lib}w.pc        $RPM_BUILD_ROOT/usr/lib/pkgconfig/${lib}.pc

done

ln -sfv libncurses++w.a $RPM_BUILD_ROOT/usr/lib/libncurses++.a
rm -vf                     $RPM_BUILD_ROOT/usr/lib/libcursesw.so

echo "INPUT(-lncursesw)" > $RPM_BUILD_ROOT/usr/lib/libcursesw.so

ln -sfv libncurses.so      $RPM_BUILD_ROOT/usr/lib/libcurses.so

ln -sfv libncursesw.a      $RPM_BUILD_ROOT/usr/lib/libcursesw.a

ln -sfv libncurses.a       $RPM_BUILD_ROOT/usr/lib/libcurses.a
mkdir -v       $RPM_BUILD_ROOT/usr/share/doc/ncurses-5.9

cp -v -R doc/* $RPM_BUILD_ROOT/usr/share/doc/ncurses-5.9


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

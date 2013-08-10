Name:           readline
Version:	6.2
Release:        1%{?dist}
Summary:	The Readline package is a set of libraries that offers command-line          editing and history capabilities.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/readline.html
Source0:        http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz

Patch0:        readline-6.2-fixes-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Readline package is a set of libraries that offers command-line          editing and history capabilities.

%prep
%setup -q
%patch0 -p1 

%build

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr --libdir=/lib
make SHLIB_LIBS=-lncurses %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/usr
mv -v $RPM_BUILD_ROOT/lib/lib{readline,history}.a $RPM_BUILD_ROOT/usr/lib
rm -v $RPM_BUILD_ROOT/lib/lib{readline,history}.so

ln -sfv ../../lib/libreadline.so.6 $RPM_BUILD_ROOT/usr/lib/libreadline.so

ln -sfv ../../lib/libhistory.so.6 $RPM_BUILD_ROOT/usr/lib/libhistory.so
mkdir   -v       $RPM_BUILD_ROOT/usr/share/doc/readline-6.2


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

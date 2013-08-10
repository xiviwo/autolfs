Name:           vim
Version:	7.3
Release:        1%{?dist}
Summary:	The Vim package contains a powerful text editor.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/vim.html
Source0:        ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Vim package contains a powerful text editor.

%prep
%setup -q -n vim73

%build
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr --enable-multibyte
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/share/doc
ln -sv ../vim/vim73/doc $RPM_BUILD_ROOT/usr/share/doc/vim-7.3
mkdir -pv $RPM_BUILD_ROOT/etc
cat > $RPM_BUILD_ROOT/etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

ln -sv vim $RPM_BUILD_ROOT/usr/bin/vi
for L in  $RPM_BUILD_ROOT/usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog



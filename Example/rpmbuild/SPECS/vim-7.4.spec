%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Vim package contains a powerful text editor. 
Name:       vim
Version:    7.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2

URL:        ftp://ftp.vim.org/pub/vim/unix
%description
 The Vim package contains a powerful text editor. 
%pre
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr --enable-multibyte
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/vim-7.4
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -svf vim ${RPM_BUILD_ROOT}/usr/bin/vi

for L in  ${RPM_BUILD_ROOT}/usr/share/man/{,*/}man1/vim.1; do

    ln -svf vim.1 $(dirname $L)/vi.1
done
ln -svf  %_sourcedir/vim/vim74/doc ${RPM_BUILD_ROOT}/usr/share/doc/vim-7.4

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif
" End /etc/vimrc
EOF

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog